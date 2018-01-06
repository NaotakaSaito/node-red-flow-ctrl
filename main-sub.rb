
require "mqtt"
require "json"
require "date"

File.open("setting.json") do |j|
  $setup = JSON.load(j)
end

def genFileName(filename)
	filepath = $setup["node-red"]["flows"].split("/")
	filename = filepath.pop
	filename = filename.split('.')
	d = DateTime.now
	str = d.strftime("%Y%m%d_%H%M%S")
	filepath.push(filename[0]+'_'+str+'.'+filename[1])
	backup_file = filepath.join('/')
	return backup_file
end
isStop = false
client = MQTT::Client.connect( $setup["mqtt"]["connection"])
client.subscribe($setup["mqtt"]["topic"])

Signal.trap(:INT) do
  puts "SIGINT"
  isStop = true
	client.disconnect()
	exit(0)
end
while isStop == false do
	client.get($setup["mqtt"]["topic"]) do |topic,message|
		backup_file = genFileName($setup["node-red"]["flows"])
		cmd = JSON.parse(message)
		print(JSON.pretty_generate(cmd)+"\n");
		if cmd.kind_of?(Hash) then
			# stop node-red
			`#{$setup["node-red"]["stop"]}`
			sleep $setup["node-red"]["interval"]
			# pickup flows from message
			if cmd.key?("flows") then
				flows = cmd["flows"]
				# backup flow
				if $setup["backup"] == true then
					`mv #{$setup["node-red"]["flows"]} #{backup_file}`
				end
				open(FLOW_FILE, 'w') do |io|
					JSON.dump(flows, io)
				end
				sleep $setup["node-red"]["interval"]
			end
			# execute script
			if cmd.key?("batch") then
				File.open("batch.sh", "w") do |f| 
					f.puts(cmd["batch"])
				end
				value = `sh batch.sh`
				print(value)
			end
			if cmd.key?("script") then
				script = cmd["script"]
				for line in script do
					value = `#{line}`
					print(value)
				end
			end
			# restart node-red
			`#{$setup["node-red"]["start"]}`
		else
			`#{$setup["node-red"]["stop"]}`
			sleep $setup["node-red"]["interval"]
			if $setup["backup"] == true then
				`mv #{$setup["node-red"]["flows"]} #{backup_file}`
			end
			open($setup["node-red"]["flows"], "w") do |io|
				JSON.dump(cmd, io)
			end
			sleep $setup["node-red"]["interval"]
			`#{$setup["node-red"]["start"]}`
		end
	end
end

