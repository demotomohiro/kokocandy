kokocandy
=========

Automatic demo video downloading and converting script

Following text is copied from kokocandy.vim

What Is This:
----------------
This is a automatic demo scene video downloading and converting script.
Best way to watch a demo is joining demo party.
And next best way is executing a demo at realtime.
If you can't do them, you need to get captured demo video to watch.
This script help you to downloading demo videos.

It also help converting video format or screen size.
When you want to enjoy demo scene with mobile phone,
it might not be able to play some videos.
Because some mobile phones don't support h264 and big screen size videos. 
This script optionally convert video so that your mobile phone can play it.

But such video have encoding noise or smaller than your screen size. 
And they require big internet traffics.(1MB demo.zip vs 100MB captured video)
So I recommend you to joining demo party or execute demo if possible.

This script read a list of URL and download best quality videos.
It optionally convert video to specific format or size with ffmpeg.
URL must be a demo page in pouet.net
e.g.
http://pouet.net/prod.php?which=60278

I wrote this script to put demo video in my phone so that I can enjoy demo
scene on my bed:)


Features:
----------------
* Input file is only URL list.
    * So even if your demo video collection were gone,
      you can rebuild it from URL list file with one command.
    * You can share favorite demo list with your friends.
      Your friend can get demo videos with one command.
* Find link to best quality video from pouet's prod page. 
* Support downloading from
    * youtube(using youtube-dl)
    * http/ftp server(using wget)
    * Not supporting capped.tv and demoscene.tv
* Auto unzip 
    * If downloaded file is compressed with zip,
      it is decompressed automatically.
* Avoid incomplete file
    * If there is any error while downloading or converting video,
	  it never be placed in destination directory.
* Avoid unnecessary downloading
    * When you change URL list or options after executing this script,
      it won't download/convert same videos again
      if the video exists in destination directory.


Dependencies:
----------------
### Following programs must be executable in command line.

* Vim ver7.3 or newer
    * http://www.vim.org/
    * For Japanese MS windows users:
      http://www.kaoriya.net/software/vim
* wget
    * Access internet.
    * For MS windows users:
      http://gnuwin32.sourceforge.net/packages/wget.htm
* youtube-dl
    * Download video from youtube.
    * http://rg3.github.com/youtube-dl/
    * Make sure that youtube-dl is up to date and you can download video in command line.
    * Use 'youtube-dl.py -U' to update it.

### Optional Dependencies:

* ffmpeg
    * Convert video format, screen size, bit rate, etc.
    * http://ffmpeg.org/
    * For MS windows users:
      http://ffmpeg.zeranoe.com/builds/
* unzip
    * Needed when you download video which is compressed by zip.
    * Some old demo videos are zipped and placed in ftp/http server.
    * For MS windows users:
      http://gnuwin32.sourceforge.net/packages/unzip.htm


How To Use:
----------------
* Easy way
    1. Put pouet's demo URL list in prods.txt and set options in kokocandy.cfg.
    2. Executee following command.  
       `vim -E -c "source kokocandy.cfg" prods.txt`
    3. Read log file(kokocandy.log) to check errors.
    4. If there are errors, check your internet,
       'Dependencies' program can working correctly
       and options in kokocandy.cfg.
    5. Then, retry the command.
       This script ignores already successfully downloaded/converted videos.
* Versatile way
    * If you know vim script language, you can make URL list in your way and
      pass it to function in kokocandy.vim.  
      `KokocandyURL(url)`  
      `KokocandyList(list)`


How This Script Work:
----------------
1. Download web page which is specified by URL.
2. Read html file and get information about demo.
   (e.g. demo title, group name, party name, etc)
   * These infos are used to make a file name and directory name to put demo video.
   You can set video path template to 'g:kokocandy_path_tmpl'
   If the video file is already exist in destination directory,
   following steps are skipped.
3. It also find link to best quality video from that html file.
   * But it sometimes get second/third best one
   when there are multiple [foo video bar] link in prod page.
   Prod page in pouet is not uniform:(
4. Download video from found URL
   * It is downloaded in g:kokocandy_temp_dir
   URL can be link to youtube or http/ftp server.
   You can set downloading command or option in  
   g:kokocandy_cmd_youtube_dl	for downloading from youtube  
   or  
   g:kokocandy_cmd_download	for http/ftp server.
5. Convert video (optional)
   Convert video format, codec or size using ffmpeg.
   You can set command or parameter for conversion in  
   g:kokocandy_cmd_vconv_ps1	and  
   g:kokocandy_cmd2_vconv_ps1	for first pass,  
   g:kokocandy_cmd_vconv_ps2	and  
   g:kokocandy_cmd2_vconv_ps2	for second pass.  
6. Move video to destination directory.
   * Directories are created according to video path template 'g:kokocandy_path_tmpl'
   File names are also renamed in same way.


TODO:
----------------
* Rewrite this script with other language(C++&Qt, C++&Boost, python etc)
  vim script don't have enough functions to easily improve this.
* Read http://pouet.net/faq.php#syndication 
* Better logging
* Support downloading demo file(not video).
* Download every available video and choose best one
* Parallel downloading and conversion.


Why I was named 'kokocandy':
----------------
I thought this script is a bit similar to Mind candy.
http://www.mindcandydvd.com/
Both help watching demo as video.
If you have a list of demo included in Mind candy,
you can make a Mind candy for mobile without extra features with this script.
'Kokoro no candy' means 'Mind candy' in japanese.
kokocandy is short for 'Kokoro no candy'.


----------------
*COOL DEMO DOWNLOADING SHOCK TO
'Japanese yAkuza Society for Rights of Authors, Composers and pure audios' s BRAIN!*
