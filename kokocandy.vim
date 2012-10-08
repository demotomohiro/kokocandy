" kokocandy (Kokoro no candy)
" Maintainer: Tomohiro
" Last Change: 2012 oct 6
"
" This is a automatic demo video downloading and converting script.
" Best way to watch a demo is joining demo party.
" And next best way is executing a demo at realtime.
" If you can't do them, you need to get captured demo video to watch.
" This script help you to downloading demo videos.
"
" It also help converting video format or screen size.
" When you want to enjoy demo scene with mobile phone,
" it might not be able to play some videos.
" Because some mobile phones don't support h264 and big screen size videos. 
" This script optionally convert video so that your mobile phone can play it.
"
" But such video might have encoding noise or smaller than your screen size. 
" And they require big internet traffics.(1MB demo.zip vs 100MB captured video)
" So I recommend you to joining demo party or execute demo if possible.
"
" This script read a list of URL and download best quality videos.
" It optionally convert video to specific format or size with ffmpeg.
" URL must be a demo page in pouet.net
" e.g.
" http://pouet.net/prod.php?which=60278
"
" I wrote this script to put demo video in my phone so that I can enjoy demo
" scene on my bed:)
"
" Features:
" - Find link to best quality video from pouet's prod page. 
" - Supporting downloading from
"     youtube(using youtube-dl)
"     http/ftp server(using wget)
"   Not supporting capped.tv and demoscene.tv
" - If downloaded file is compressed with zip,
"   it decompress the file automatically.
" - If there is any error while downloading or converting video,
"   it never be placed in destination directory.
" - When you change URL list or options after executing this script,
"   it won't download/convert same videos again
"   if the video exists in distination directory.
"
"
" Dependencies:
" - Following programs must be executable in command line.
"
" Vim ver7.3 or newer
"
" wget
"   - Access internet.
"   - For MS windows users:
"     http://gnuwin32.sourceforge.net/packages/wget.htm
"
" youtube-dl
"   - Download video from youtube.
"   - http://rg3.github.com/youtube-dl/
"   - Make sure that youtube-dl is up to date and you can download video in command line.
"   - Use 'youtube-dl.py -U' to update it.
"
" Optional Dependencies:
" ffmpeg
"   - Convert video format, screen size, bit rate, etc.
"   - http://ffmpeg.org/
"   - For MS windows users:
"     http://ffmpeg.zeranoe.com/builds/
"
" unzip
"   - Needed when you download video which is compressed by zip.
"   - For MS windows users:
"     http://gnuwin32.sourceforge.net/packages/unzip.htm
"
" How To Use:
" 1. Easy way
"   Put pouet's demo URL list in prods.txt and set options in kokocandy.cfg.
"   Executee following command.
"   vim -E -c "source kokocandy.cfg" prods.txt
"   Read log file(kokocandy.log) to check errors.
"   If there are errors, check your internet,
"   'Dependencies' program can working correctly
"   and options in kokocandy.cfg.
"   Then, retry the command.
"   This script ignores already successfully downloaded/converted videos.
"
" 2. Versatile way
"   If you know vim script language, you can make URL list in your way and
"   pass it to function in kokocandy.vim.
"   KokocandyURL(url)
"	KokocandyList(list)
"
" How This Script Work:
" 1 Download web page which is specified by URL.
" 2 Read html file and get information about demo.
"   (e.g. demo title, group name, party name, etc)
"   These infos are used to make a file name and directory name to put demo
"   video.
"   You can set video path template to 'g:kokocandy_path_tmpl'
"   If the video file is already exist in destination directory,
"   following steps are skipped.
" 3 It also find link to best quality video from that html file.
"   But it sometimes get second/third best one
"   when there are multiple [foo video bar] link in prod page.
"   Prod page in pouet is not uniform:(
" 4 Download video from found URL
"   It is download in g:kokocandy_temp_dir
"   URL can be link to youtube or http/ftp server.
"   You can set downloading command or option in
"   g:kokocandy_cmd_youtube_dl	for downloading from youtube
"   or
"	g:kokocandy_cmd_download	for http/ftp server.
" 5 Convert video (optional)
"   Convert video format, codec or size using ffmpeg.
"	You can set command or parameter for conversion in
"	g:kokocandy_cmd_vconv_ps1	and
"	g:kokocandy_cmd2_vconv_ps1	for first pass,
"	g:kokocandy_cmd_vconv_ps2	and
"	g:kokocandy_cmd2_vconv_ps2	for second pass.
" 6 Move video to destination directory.
"
" TODO:
" - Rewrite this with other language(C++&Qt, C++&Boost, python etc)
"   vim script don't have enough functions to make this kind of program.
" - Read http://pouet.net/faq.php#syndication 
" - Better logging
" - Support downloading demo file(not video).
" - Download every available video and choose best one
" - Parallel downloading and conversion.
"
"
" COOL DEMO DOWNLOADING SHOCK TO
" 'Japanese yAkuza Society for Rights of Authors, Composers and pure audios' s BRAIN!
"

"if exists("g:loaded_kokocandy")
"	finish
"endif
"let g:loaded_kokocandy = 1

"--------------------------------
" Global variables
"--------------------------------
function! s:InitGblVar(name, value)
	if !exists(a:name)
		if type(a:value)==1
			execute "let ".a:name."="."'".a:value."'"
		else
			execute "let ".a:name."=".a:value
		endif
	endif
endfunction

"Set how videos are named and which directory they are placed.
"'{title}', '{group}', '{year}' and etc are substituted with corresponding info of the demo.
call s:InitGblVar("g:kokocandy_path_tmpl", "{year}/{party}/{type}/[{rank}]{title} by {group}.mp4")
"Destination directory.
"Video file is moved to this directory
"after downloading and conversion was successfully completed.
call s:InitGblVar("g:kokocandy_dist_dir", "dist")
"Temporary directory.
"Video file is downloaded and converted here.
call s:InitGblVar("g:kokocandy_temp_dir", "temp")

"If value is 1, display messages from external command.
call s:InitGblVar("g:kokocandy_is_show_cmd_msg", 0)
let s:kokocandy_cmd_prefix = g:kokocandy_is_show_cmd_msg ? "keepjumps " : "silent keepjumps "

"If value is 1, display progress.
call s:InitGblVar("g:kokocandy_is_show_progress", 1)
call s:InitGblVar("g:kokocandy_is_show_verbose", 0)

"If value is 1, convert video to specific format.
"0 to skipping conversion.
call s:InitGblVar("g:kokocandy_is_convert_video", 1)

"Suffix for temporary file
"call s:InitGblVar("g:kokocandy_tmp_suffix", '.temp')

call s:InitGblVar("g:kokocandy_suffix_downloading",	'.downloading')
call s:InitGblVar("g:kokocandy_suffix_downloaded",	'.downloaded')
call s:InitGblVar("g:kokocandy_suffix_converting",	'.converting')
call s:InitGblVar("g:kokocandy_suffix_converted",	'.converted')

"--------------------------------
" External Commands
"--------------------------------
if !executable("wget")
	echo "I need wget!"
	finish
endif
call s:InitGblVar("g:kokocandy_cmd_get_html", "wget -q -O - ")
call s:InitGblVar("g:kokocandy_cmd_get_server_response", "wget --spider --server-response ")
call s:InitGblVar("g:kokocandy_cmd_download", "wget --force-directories -O ")

"This command is used to download demo video.
if executable("youtube-dl")
	call s:InitGblVar("g:kokocandy_cmd_youtube_dl", "youtube-dl -o ")
elseif executable("youtube-dl.py")
	call s:InitGblVar("g:kokocandy_cmd_youtube_dl", "youtube-dl.py -o ")
else
	echo "No command to download video is available"
	echo "Please install youtube-dl"
	finish
endif
call s:InitGblVar("g:kokocandy_cmd2_youtube_dl", "")

if g:kokocandy_is_convert_video
	if !executable("ffmpeg")
		echo "I need ffmpeg to convert video!"
		echo "If you don't convert videos, :let g:kokocandy_is_convert_video=0"
		finish
	endif
	"ffmpeg command for 2 pass encoding.
	"Following option is optimal for my phone(SoftBank 103p):)
	call s:InitGblVar("g:kokocandy_cmd_vconv_ps1", 'ffmpeg -i ')
	call s:InitGblVar("g:kokocandy_cmd2_vconv_ps1", ' -f mp4 -c:v mpeg4 -b:v 2048k -r 30 -pass 1 -vf scale="if(gte(a\,640/360)\,min(640\,iw)+1)-1:if(lt(a\,640/360)\,min(360\,ih)+1)-1" -an -y NUL ')
	"If conversion with default option was failed, conversion with
	"back up option is executed and pass 2 command is also executed with back
	"up option.
	"If back up option is empty, backup conversion is not executed.
	"
	"ffmpeg sometimes fail if you dont set -r option(frame rate).
	"And such case might be able to solved by setting -r 25 option..
	call s:InitGblVar("g:kokocandy_cmd2_vconv_ps1_bkup", '')

	call s:InitGblVar("g:kokocandy_cmd_vconv_ps2", 'ffmpeg -i ')
	call s:InitGblVar("g:kokocandy_cmd2_vconv_ps2", ' -f mp4 -c:v mpeg4 -b:v 2048k -r 30 -pass 2 -vf scale="if(gte(a\,640/360)\,min(640\,iw)+1)-1:if(lt(a\,640/360)\,min(360\,ih)+1)-1" ')
	call s:InitGblVar("g:kokocandy_cmd2_vconv_ps2_bkup", '')
endif

call s:InitGblVar("g:kokocandy_cmd_unzip", 'unzip -o ')

"--------------------------------
" Internal Constants
"--------------------------------
let s:videoExts = ["avi", "mp4", "mkv", "mpg", "wmv"]
let s:videoExtsPattern  = '\('.join(map(copy(s:videoExts), '"\\(".v:val."\\)"'), '\|').'\)'

"--------------------------------
" Internal functions
"--------------------------------
function! s:Echo(str, isEcho)
	if exists("s:message")
		let s:message .= a:str."\n"
	endif
	if a:isEcho
		echo a:str
	endif
endfunction

function! s:EchoProgress(str)
	call s:Echo(a:str, g:kokocandy_is_show_progress)
endfunction

function! s:EchoVerbose(str)
	call s:Echo(a:str, g:kokocandy_is_show_verbose)
endfunction

function! s:EchoError(str)
	call s:Echo(a:str, 1)
endfunction

function! s:TmplExpand(tmpl, name, value)
	return substitute(a:tmpl, "{".a:name."}", escape(a:value, "\\^$.~[]&"), "g")
endfunction

"Replace charactors which cannot be used in file name to space.
function! s:ReplaceBadFileNameChar(fileName)
	let badChars = '\/:*?"<>|'
	return tr(a:fileName, badChars, repeat(' ', strlen(badChars)))
endfunction

function! s:ExecCmd(cmd)
	call s:Echo(a:cmd, g:kokocandy_is_show_cmd_msg)
	execute s:kokocandy_cmd_prefix." ! ".a:cmd
endfunction

"Get parent dir from file path
function! s:GetParentDir(path)
	return matchstr(a:path, "\\zs.*\\ze[/\\\\]")
endfunction

function! s:MakeParentDir(path)
	let dir = s:GetParentDir(a:path)
	if getftype(dir)==""
		call mkdir(dir, "p")
	endif

	return dir
endfunction

function! s:System(cmd)
	call s:Echo(a:cmd, g:kokocandy_is_show_cmd_msg)
	let src = system(a:cmd)
	return src
endfunction

function! s:GetHtml(url)
	"Don't set 1 in second argument of shellescape when using system()
	let cmd = g:kokocandy_cmd_get_html.shellescape(a:url)
	let src = s:System(cmd)
	if v:shell_error
		call s:EchoError("Failed to access '".a:url."'")
		return ""
	endif

	return src
endfunction

function! s:GetTagContent(text, tag)
	return matchstr(a:text, "<\\s*\\<".a:tag."\\>[^>]*>\\zs.\\{-}\\ze<\\/\\<".a:tag."\\>\\s*>")
endfunction

function! s:GetProdInfo(src, type)
	return
	\	substitute(
	\		matchstr(a:src, " ".a:type." :[[:blank:]\\n]*\\zs\\S.\\{-}\\ze\\s*\\n"),
	\		"[[:blank:]\\n]\\+",
	\		" ",
	\		"g")
endfunction

function! s:GetDirectVideoURL(url)
	if a:url =~ "^http://www.scene.org/file.php"
		let src = s:GetHtml(a:url)
		if src == ""
			return ""
		endif
		let src	= substitute(src, "&amp;", "\\&", "g")
		let link = matchstr(src, "<a\\s\\+href=\"\\zs\\/file_dl\\.php.\\{-}\\ze\"")
		if link==""
			call s:EchoError("I can't find download link from '".a:url."'")
			return ""
		endif
		return "http://www.scene.org".link
	endif

	if a:url =~ "^ftp:"
		return a:url
	endif

	let response = s:System(g:kokocandy_cmd_get_server_response." ".shellescape(a:url))
	if response =~ "\n\\s*HTTP/1\\.[01] 200 OK\n" &&
	\	response =~ "\n\\s*Content-Type: text/html"
		"It is normal html file! Find link to the video!
		let src = s:GetHtml(a:url)
		if src == ""
			return ""
		endif
		let src	= substitute(src, "&amp;", "\\&", "g")
		let link = ""
		for i in range(1, 8)
			let link =
			\	matchstr(
			\		src,
			\		"<a\\s\\+href=\"\\zsftp:[^\"]*\\.".s:videoExtsPattern."\\ze\"",
			\		0,
			\		i)
			if link == ""
				return ""
			endif
			let response = s:System(g:kokocandy_cmd_get_server_response." ".shellescape(link))
			if response =~ "\n230\\>"
				break
			endif
			let link = ""
		endfor

		return link
	endif

	"If this url is not direct link to video, I have no idea how to get one.
	return a:url
endfunction

function! s:FindBestVideoURL(src)
	"My strategy is,
	"link name "video.*h.*" is a link to best video.
	"(e.g. video hq, video hires, video high quality)
	"if no such link name,
	"link name "video" is a link to best video
	"if no such link name,
	"youtube would have best video.
	"
	"It seems that youtube dont have good quality video of classic demo,
	"but has good quality video of modern demo.

	"TODO: This code get a link to second best video in elevated page(52938)
	let linkName =
	\	matchstr(a:src, "<a\\s\\+href=\"[^\"]*\"[^>]*>\\s*\\zsvideo[^<]*h[^<]*\\ze<")
	if linkName!=""
		let url =
		\	matchstr(
		\		a:src, "<a\\s\\+href=\"\\zs[^\"]*\\ze\"[^>]*>\\s*video[^<]*h[^<]*<")
		call s:EchoVerbose(linkName." is link to ".url)
		return s:GetDirectVideoURL(url)
	endif

	let linkName = matchstr(a:src, "<a\\s\\+href=\"[^\"]*\"[^>]*>\\s*\\zsvideo[^<]*\\ze<")
	if linkName!=""
		let url = matchstr(a:src, "<a\\s\\+href=\"\\zs[^\"]*\\ze\"[^>]*>\\s*video[^<]*<")
		call s:EchoVerbose(linkName." is link to ".url)
		return s:GetDirectVideoURL(url)
	endif

	let url		= matchstr(a:src, "\"\\zs[^\"]\\+\\ze\">youtube")
	return url
endfunction

function! s:ProcessSrc(src, nameTmpl)
"	let src = join(getline(1, "$"))
	let src 		= substitute(a:src, "&amp;", "\\&", "g")
	let titleAndGroup = s:GetTagContent(src, "title")
	if titleAndGroup==""
		call s:EchoError("Failed to get title and group name")
		return ["", ""]
	endif
	let title		= matchstr(titleAndGroup, "\\zs.*\\ze by ")
	if title == ""
		let title = titleAndGroup
	endif
	let group		= matchstr(titleAndGroup, " by \\zs.*\\ze")
	let srcNoTag	= substitute(src, "<.\\{-}>\\|&nbsp;", " ", "g")
"	let srcNoTag	= substitute(srcNoTag, "[[:blank:]\\n]\\+", " ", "g")
	let platform	= s:GetProdInfo(srcNoTag, "platform")
	let type		= s:GetProdInfo(srcNoTag, "type")
	let date		= s:GetProdInfo(srcNoTag, "release date")
	let party		= s:GetProdInfo(srcNoTag, "release party")
	let rank		= s:GetProdInfo(srcNoTag, "ranked")
	let rank		= substitute(rank,	" ", "", "")
	let year		= matchstr(date, "\\d\\+")
	let nameDict	=
	\	{
	\		'titleAndGroup': titleAndGroup,	'title': title,	'group': group,
	\		'platform': platform,			'type': type,
	\		'date': date,					'year': year,	'party': party,
	\		'rank': rank
	\	}

	call map(nameDict, 's:ReplaceBadFileNameChar(v:val)')
	call s:EchoVerbose(string(nameDict))

	let path		= a:nameTmpl

	for key in keys(nameDict)
		let path = s:TmplExpand(path, key, nameDict[key])
	endfor

	let videoURL	= s:FindBestVideoURL(src)

	return [videoURL, path]
endfunction

function! s:DownloadVideo(url, outFile)
	call s:EchoProgress("Downloading ".a:outFile." from ".a:url)

	let httpHeadPat = "^\\(https\\?://\\)\\?\\(www\\.\\)\\?"
	if a:url =~ httpHeadPat."youtube\\." || a:url =~ httpHeadPat."youtu.be"
		"a:url is youtube
		let cmd = g:kokocandy_cmd_youtube_dl." ".shellescape(a:outFile, 1)." ".g:kokocandy_cmd2_youtube_dl." ".shellescape(a:url, 1)
		call s:ExecCmd(cmd)
	else
		call s:MakeParentDir(a:outFile)
		call s:ExecCmd(g:kokocandy_cmd_download." ".shellescape(a:outFile, 1)." ".shellescape(a:url, 1))
		if a:url =~ "\\.zip\\(&.*\\)\\?$"
			if !executable('unzip')
				call s:EchoError("'unzip' is needed!")
				return 2
			endif
			let msg =
			\	s:System(
			\		g:kokocandy_cmd_unzip." ".shellescape(a:outFile)." -d ".shellescape(s:GetParentDir(a:outFile)))
			if v:shell_error
				call s:EchoError("Failed to unzip '".a:outFile."'")
				return 3
			endif

			let ofile =
			\	matchstr(
			\		msg,
			\		"\\s*inflating: \\zs".
			\		"[^\n]*\\.".s:videoExtsPattern.
			\		"\\ze\\s*")
			if ofile=="" || getftype(ofile)==""
				call s:EchoError("No video file was found in '".a:outFile."'")
				return 4
			endif
			call delete(a:outFile)
			call rename(ofile, a:outFile)
		endif
	endif

	if v:shell_error || getftype(a:outFile)==""
		return 1
	endif
endfunction

function! s:ConvertVideo(file, outFile)
	call s:EchoProgress("Converting ".a:file)

	let isUseBkupOpt = 0

	if g:kokocandy_cmd_vconv_ps1!=""
		let cmd1 =
		\	g:kokocandy_cmd_vconv_ps1." ".shellescape(a:file, 1)." ".
		\	g:kokocandy_cmd2_vconv_ps1
		call s:ExecCmd(cmd1)

		if v:shell_error
			"If failed, retry conversion with back up option if it is available!
			let isUseBkupOpt =
			\	(g:kokocandy_cmd2_vconv_ps1_bkup!="") && (g:kokocandy_cmd2_vconv_ps2_bkup!="")
			if isUseBkupOpt
				let cmd1 =
				\	g:kokocandy_cmd_vconv_ps1." ".shellescape(a:file, 1)." ".
				\	g:kokocandy_cmd2_vconv_ps1_bkup
				call s:ExecCmd(cmd1)
			endif
		endif

		if v:shell_error
			call s:EchoError("Failed to convert '".a:file."' in pass 1")
			call delete(a:outFile)
			return 1
		endif
	endif

	let cmd2 =
	\	g:kokocandy_cmd_vconv_ps2." ".shellescape(a:file, 1)." ".
	\	(isUseBkupOpt ? g:kokocandy_cmd2_vconv_ps2_bkup : g:kokocandy_cmd2_vconv_ps2)." ".
	\	shellescape(a:outFile, 1)
	call s:ExecCmd(cmd2)

	if v:shell_error
		call s:EchoError("Failed to convert '".a:file."' in pass 2")
		call delete(a:outFile)
		return 2
	endif
endfunction

"--------------------------------
" Export functions
"--------------------------------
function! KokocandyURL(url)
	let url = a:url
	if url =~ 'pouet.net/'
		let url = url.'&howmanycomments=0'
	endif
	call s:EchoProgress("Reading ".url)

	let src = s:GetHtml(url)
	if src==""
		return 1
	endif

	let [link, path] = s:ProcessSrc(src, g:kokocandy_path_tmpl)

	let distPath = g:kokocandy_dist_dir."/".path
	if getftype(distPath)!=""
		call s:EchoProgress(distPath." is already exist. skipping it.")
		return 0
	endif

	if link==""
		echo "No link to video in ".a:url
		return 2
	endif

"	echo "Download url: ".link

	let downloadPath	= g:kokocandy_temp_dir."/".path
	let downloadingPath	= downloadPath.g:kokocandy_suffix_downloading
	let downloadedPath	= downloadPath.g:kokocandy_suffix_downloaded
	let convertingPath	= downloadPath.g:kokocandy_suffix_converting
	let convertedPath	= downloadPath.g:kokocandy_suffix_converted

	let isDownloaded	= getftype(downloadedPath)!=""
	let isConverted		= getftype(convertedPath)!=""
	let isDoDownload	= g:kokocandy_is_convert_video ? (!isDownloaded && !isConverted) : !isDownloaded
	let isDoConvert		= g:kokocandy_is_convert_video && !isConverted

"	echo "downloadingPath: ".downloadingPath

	if isDoDownload
		if s:DownloadVideo(link, downloadingPath)
			call s:EchoError(
			\	"Failed to download '".downloadPath."' from '".link."'(".url.")")
			return 3
		endif
		if rename(downloadingPath, downloadedPath)
			call s:EchoError(
			\	"Failed to rename '".downloadingPath."' to '".downloadedPath."'")
			return 5
		endif
	endif

	if isDoConvert
		if s:ConvertVideo(downloadedPath, convertingPath)
			call s:EchoError("Failed to convert '".downloadedPath."'")
			return 4
		endif

		if rename(convertingPath, convertedPath)
			call s:EchoError(
			\	"Failed to rename '".convertingPath."' to '".convertedPath."'")
			return 5
		endif

		if delete(downloadedPath)
			call s:EchoError("Failed to delete '".downloadedPath."'")
			call s:EchoError("It is original file. Converted file is '".convertedPath."'")
			return 5
		endif
	endif

	let srcPath = g:kokocandy_is_convert_video ? convertedPath : downloadedPath
	call s:MakeParentDir(distPath)
	if rename(srcPath, distPath)
		call s:EchoError("Failed to rename '".srcPath."' to '".distPath."'")
		return 6
	endif
endfunction

function! KokocandyList(list)
	call filter(a:list, 'v:val =~ "^http://"')
	let numlist = len(a:list)
	let progress = 1

	let failList = []
	for url in a:list
		"All echo messages from KokocandyURL are written in s:message.
		let s:message = ""
		call s:EchoProgress(progress."/".numlist)
		let retVal = KokocandyURL(url)
		if retVal
			call add(failList, [url, s:message])
		endif
		let progress += 1
	endfor

	if !empty(failList)
		echo "Failed URL list:"
		for item in failList
			echo item[0]
			echo item[1]
			echo "\n"
		endfor

		return 1
	else
		echo "Completed! There is no error."
	endif
endfunction

function! KokocandyFile(inputFile)
	let list = readfile(a:inputFile)
	call KokocandyList(list)
endfunction

function! KokocandyCrntBuf()
	call KokocandyList(getline(1, "$"))
endfunction

"command! -complete=file -nargs=1 KokocandyFile call KokocandyFile(<q-args>)
"redir! > script.log
"KokocandyFile prods_small.txt
"redir END
