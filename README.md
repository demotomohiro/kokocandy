kokocandy
=========

Automatic demo video downloading and converting script

This is a automatic demo video downloading and converting script.
Best way to watch a demo is joining demo party.
And next best way is executing a demo at realtime.
If you can't do them, you need to get captured demo video to watch.
But such video might have encoding noise or smaller than your screen size. 
And they require big internet traffics.(1MB demo.zip vs 100MB captured video)
This script was made for help downloading and converting demo videos.

It read a list of URL and download best quality videos.
It optionally convert video to specific format or size with ffmpeg.
URL must be a demo page in pouet.net

I wrote this script to put demo video in my phone so that I can enjoy demo
scene on my bed:)

Dependencies:
- Following programs must be executable in command line.

Vim ver7.3 or newer

wget
  - Access internet.
  - For MS windows users:
    http://gnuwin32.sourceforge.net/packages/wget.htm

youtube-dl
  - Download video from youtube.
  - http://rg3.github.com/youtube-dl/
  - Make sure that youtube-dl is up to date and you can download video in command line.
  - Use 'youtube-dl.py -U' to update it.

Optional Dependencies:
ffmpeg
  - Convert video format, screen size, bit rate, etc.
  - http://ffmpeg.org/
  - For MS windows users:
    http://ffmpeg.zeranoe.com/builds/

unzip
  - Needed when you download video which is compressed by zip.
  - For MS windows users:
    http://gnuwin32.sourceforge.net/packages/unzip.htm

How To Use:
1. Easy way
  Put pouet's demo URL list in prods.txt and set options in kokocandy.cfg.
  Executee following command.
  vim -E -c "source kokocandy.cfg" prods.txt
  Read log file(kokocandy.log) to check errors.
  If there are errors, check your internet,
  'Dependencies' program can working correctly
  and options in kokocandy.cfg.
  Retry execute the command. This script don't download already downloaded videos.

2. Versatile way
  If you know vim script language, you can make URL list in your way and
  pass it to function in kokocandy.vim.
  KokocandyURL(url)
  KokocandyList(list)

How This Script Work:
1 Download web page which is specified by URL.
2 Read html file and get information about demo.
  (e.g. demo title, group name, party name, etc)
  These infos are used to make a file name and directory name to put demo
  video.
  You can set video path template to 'g:kokocandy_path_tmpl'
  If the video file is already exist in distination directory,
  following steps are skipped.
3 It also find link to best quality video from that html file.
  But it sometimes get second/third best one
  when there are multiple [foo video bar] link in prod page.
  Prod page in pouet is not uniform:(
4 Download video from found URL
  It is download in g:kokocandy_temp_dir
  URL can be link to youtube or http/ftp server.
  You can set downloading command or option in
  g:kokocandy_cmd_youtube_dl	for downloading from youtube
  or
  g:kokocandy_cmd_download	for http/ftp server.
5 Convert video (optional)
  Convert video format, codec or size using ffmpeg.
  You can set command or parameter for conversion in
  g:kokocandy_cmd_vconv_ps1	and
  g:kokocandy_cmd2_vconv_ps1	for first pass,
  g:kokocandy_cmd_vconv_ps2	and
  g:kokocandy_cmd2_vconv_ps2	for second pass.
6 Move video to destination directory.

TODO:
- Rewrite this with other language(C++&Qt, C++&Boost, python etc)
  vim script don't have enough functions to make this kind of program.
- Read http://pouet.net/faq.php#syndication 
- Support downloading demo file(not video).


COOL DEMO DOWNLOADING SHOCK TO
'Japanese yAkuza Society for Rights of Authors, Composers and pure audios' s BRAIN!
