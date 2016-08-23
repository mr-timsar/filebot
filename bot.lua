package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  ..';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'
URL = require('socket.url')
JSON = require('dkjson')
HTTPS = require('ssl.https')
----config----
local bot_api_key = ""--توکن بوت را درون " قرار دهید --
local BASE_URL = "https://api.telegram.org/bot"..bot_api_key
local BASE_FOLDER = ""


-------

----utilites----

function is_admin(msg)-- Check if user is admin or not
  local var = false
  local admins = {94746365}-- put your id here
  for k,v in pairs(admins) do
    if msg.from.id == v then
      var = true
    end
  end
  return var
end

function sendRequest(url)
	local printing = print(url)
  local dat, res = HTTPS.request(url)
  local tab = JSON.decode(dat)

  if res ~= 200 then
    return false, res
  end

  if not tab.ok then
    return false, tab.description
  end

  return tab

end

function getMe()--https://core.telegram.org/bots/api#getfile
    local url = BASE_URL .. '/getMe'
  return sendRequest(url)
end

function getUpdates(offset)--https://core.telegram.org/bots/api#getupdates

  local url = BASE_URL .. '/getUpdates?timeout=20'

  if offset then

    url = url .. '&offset=' .. offset

  end

  return sendRequest(url)

end
sendSticker = function(chat_id, sticker, reply_to_message_id)

	local url = BASE_URL .. '/sendSticker'

	local curl_command = 'curl -s "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "sticker=@' .. sticker .. '"'
-- 
	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end

	io.popen(curl_command):read("*all")
	return end

sendPhoto = function(chat_id, photo, caption, reply_to_message_id)

	local url = BASE_URL .. '/sendPhoto'

	local curl_command = 'curl -s "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "photo=@' .. photo .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end

	if caption then
		curl_command = curl_command .. ' -F "caption=' .. caption .. '"'
	end

	io.popen(curl_command):read("*all")
	return end
sendPhotoID = function(chat_id, photo_id, caption, reply_to_message_id)

	local url = BASE_URL .. '/sendPhoto'

	url = url .. '?chat_id=' .. chat_id .. '&photo=' .. photo_id 

	if reply_to_message_id then
		url = url .. 'reply_to_message_id=' .. reply_to_message_id 
	end

	if caption then
		url = url .. '&caption=' .. caption
	end

	return sendRequest(url)
	 end

forwardMessage = function(chat_id, from_chat_id, message_id)

	local url = BASE_URL .. '/forwardMessage?chat_id=' .. chat_id .. '&from_chat_id=' .. from_chat_id .. '&message_id=' .. message_id

	return sendRequest(url)

end

function sendMessage(chat_id, text, disable_web_page_preview, reply_to_message_id, use_markdown)--https://core.telegram.org/bots/api#sendmessage

	local url = BASE_URL .. '/sendMessage?chat_id=' .. chat_id .. '&text=' .. URL.escape(text)

	if disable_web_page_preview == true then
		url = url .. '&disable_web_page_preview=true'
	end

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end

	if use_markdown then
		url = url .. '&parse_mode=Markdown'
	end

	return sendRequest(url)

end



getuserprofilephotos = function (user_id,limit)
 	local url = BASE_URL .. '/getUserProfilePhotos?user_id='.. user_id .. '&limit=' .. limit
	return sendRequest(url)
end
senduserprofilephotos = function (chat_id,find_id,caption)
	local photo = getuserprofilephotos(find_id,1)
	sendPhotoID(chat_id,photo.result.photos[1][1].file_id,URL.escape(caption))
end

local function save_file(name, text)
    local file = io.open("data/"..name, "w")
    file:write(text)
    file:flush()
    file:close()
end   

function sendDocument(chat_id, document, reply_to_message_id)--https://github.com/topkecleon/otouto/blob/master/bindings.lua

	local url = BASE_URL .. '/sendDocument'

	local curl_command = 'cd \''..BASE_FOLDER..currect_folder..'\' && curl -s "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "document=@' .. document .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end
	io.popen(curl_command):read("*all")
	return

end
function download_to_file(url, file_name, file_path)--https://github.com/yagop/telegram-bot/blob/master/bot/utils.lua
  print("url to download: "..url)

  local respbody = {}
  local options = {
    url = url,
    sink = ltn12.sink.table(respbody),
    redirect = true
  }
  -- nil, code, headers, status
  local response = nil
    options.redirect = false
    response = {HTTPS.request(options)}
  local code = response[2]
  local headers = response[3]
  local status = response[4]
  if code ~= 200 then return nil end
  local file_path = BASE_FOLDER..currect_folder..file_name

  print("Saved to: "..file_path)

  file = io.open(file_path, "w+")
  file:write(table.concat(respbody))
  file:close()
  return file_path
end
--------

function bot_run()
	bot = nil

	while not bot do -- Get bot info
		bot = getMe()
	end

	bot = bot.result

	local bot_info = "Username = @"..bot.username.."\nName = "..bot.first_name.."\nId = "..bot.id.." \nBeatBot hyper bot :)\ntnx to @imandaneshi & @Unfriendly\neditor: @amirho3inf \nchannel : @BeatBot_Team"

	print(bot_info)

	last_update = last_update or 0

	is_running = true

	currect_folder = ""
end

function msg_processor(msg)
	if msg.new_chat_participant or msg.new_chat_title or msg.new_chat_photo or msg.left_chat_participant then return end
	if msg.audio or msg.document or msg.video or msg.voice then return end -- Admins only !
	if msg.date < os.time() - 5 then -- Ignore old msgs
		return
    end

  if msg.sticker then
 	return
  

  elseif msg.photo then
	return
 
 elseif msg.text:match("^[/!#](create) ([^%s]+) (.+)$") then
 local matches = { string.match(msg.text, "^[/!](create) ([^%s]+) (.+)$") }
  local name = matches[2]
	local text = matches[3]
  local saving = save_file(name, text)
	local sending = sendDocument(msg.chat.id,"data/"..name)
	local text = sendMessage(msg.chat.id,"_!فایل_ \n _["..matches[2].."]_ \n`ساخته شد✅`",true,false,true)
	

elseif msg.text:match("^[!#/][sS]tart") then
		local start = "سلام"
 .."\n"..msg.from.first_name
 .."\n😁❤️"
.."\nبرای دریافت متن راهنما دستور"
.."\n/help"
 .."\nرو بفرست 😊"
.."\nموفق باشی!"
local text = senduserprofilephotos(msg.chat.id,msg.from.id,start)
elseif msg.text:match("^[!#/][Hh]elp") then
	local help = [[_سلام دوست من 😀❤️

من یه ربات هستم برای تبدیل متن به فایل و فرمت های مورد نظرت_
====================
_تبدیل متن به فایل  و فرمت مورد نظر_
/create test.lua salam
====================
_تمامی فرمت ها ساپورت میشوند_
====================
 *نکته ی مهم*

2- این ربات برای سوپر گروه و گروه نیست از این ربات فقط در پیوی استفاده کنید

3- فقط زبان انگلیسی ساپورت میشود

برای فهمیدن ورژن ربات از دستور 
 /version
استفاده کن
*موفق باشی*]]
		sendMessage(msg.chat.id,help,true,false,true)
elseif msg.text:match("^[!#/][Vv]ersion") then
	local version = [[Create file bot 
Version 1
based on `lua-api-bot` by *PaYeDaR*
============================
 [Developer: mrhalix](https://telegram.me/Mrhalix)
 [Developer: luaCrative](https://telegram.me/luacractive/)
 Special thanks to [ALIREZA](https://telegram.me/alirezamee/) AND [AMIR SBSS](https://telegram.me/amir_h/)]]
	sendMessage(msg.chat.id,version,true,false,true)
return end

end
bot_run() -- Run main function
while is_running do -- Start a loop witch receive messages.
	local response = getUpdates(last_update+1) -- Get the latest updates using getUpdates method
	if response then
		for i,v in ipairs(response.result) do
			last_update = v.update_id
			msg_processor(v.message)
		end
	else
		print("Conection failed")
	end

end
print("Bot halted")
