require 'formula'

class Mutt < Formula
  homepage 'http://www.mutt.org/'
  url "ftp://ftp.mutt.org/mutt/mutt-1.5.23.tar.gz"
  mirror "http://fossies.org/linux/misc/mutt-1.5.23.tar.gz"
  sha1 "8ac821d8b1e25504a31bf5fda9c08d93a4acc862"
  revision 2

  head do
    url 'http://dev.mutt.org/hg/mutt#HEAD', :using => :hg

    resource 'html' do
      url 'http://dev.mutt.org/doc/manual.html', :using => :nounzip
    end

    depends_on :autoconf
    depends_on :automake
  end

  option "with-debug", "Build with debug option enabled"
  option "with-sidebar-patch", "Apply sidebar (folder list) patch" unless build.head?
  option "with-trash-patch", "Apply trash folder patch"
  option "with-slang", "Build against slang instead of ncurses"
  option "with-ignore-thread-patch", "Apply ignore-thread patch"
  option "with-pgp-verbose-mime-patch", "Apply PGP verbose mime patch"
  option "with-pgp-multiple-crypt-hook-patch", "Apply PGP multiple-crypti-hook patch"
  option "with-confirm-attachment-patch", "Apply confirm attachment patch"
  option "with-tls-ciphers-patch", "Apply configure TLS ciphers patch"

  depends_on 'tokyo-cabinet'
  depends_on 's-lang' => :optional
  depends_on 'openssl' if build.with? "tls-ciphers-patch"

  def patches
    urls = [
      ['with-sidebar-patch', 'https://raw.github.com/nedos/mutt-sidebar-patch/master/mutt-sidebar.patch'],
      ['^with-trash-patch', 'ftp://ftp.openbsd.org/pub/OpenBSD/distfiles/mutt/trashfolder-1.5.22.diff0.gz'],
      # original source for this went missing, patch sourced from Arch at
      # https://aur.archlinux.org/packages/mutt-ignore-thread/
      ['with-ignore-thread-patch', 'https://gist.github.com/mistydemeo/5522742/raw/1439cc157ab673dc8061784829eea267cd736624/ignore-thread-1.5.21.patch'],
      ['with-pgp-verbose-mime-patch',
          'https://raw.githubusercontent.com/psych0tik/mutt/73c09bc56e79605cf421a31c7e36958422055a20/debian/patches/features-old/patch-1. 5.4.vk.pgp_verbose_mime'],
      ['with-pgp-multiple-crypt-hook-patch',
          'http://localhost.lu/mutt/patches/patch-1.5.22.sc.multiple-crypt-hook.1'],
      ['with-pgp-combined-crypt-hook-patch',
          'http://localhost.lu/mutt/patches/patch-1.5.22.sc.crypt-combined.1'],
      ['with-confirm-attachment-patch', 'https://gist.github.com/tlvince/5741641/raw/c926ca307dc97727c2bd88a84dcb0d7ac3bb4bf5/mutt-attach.patch'],
      ['with-tls-ciphers-patch', 'http://dev.mutt.org/trac/raw-attachment/ticket/3167/mutt-ssl-ciphers-patch.diff' ]
    ]

    if build.with? "ignore-thread-patch" and build.with? "sidebar-patch"
      puts "\n"
      onoe "The ignore-thread-patch and sidebar-patch options are mutually exlusive. Please pick one"
      exit 1
    end

    p = []
    urls.each do |u|
      p << u[1] if build.include? u[0]
    end

    return p
  end

  def install
    args = ["--disable-dependency-tracking",
            "--disable-warnings",
            "--prefix=#{prefix}",
            "--with-ssl",
            "--with-sasl",
            "--with-gss",
            "--enable-imap",
            "--enable-smtp",
            "--enable-pop",
            "--enable-hcache",
            "--with-tokyocabinet",
            # This is just a trick to keep 'make install' from trying to chgrp
            # the mutt_dotlock file (which we can't do if we're running as an
            # unpriviledged user)
            "--with-homespool=.mbox"]
    args << "--with-slang" if build.with? 's-lang'

    if build.with? 'debug'
      args << "--enable-debug"
    else
      args << "--disable-debug"
    end

    if build.head?
      system "./prepare", *args
    else
      system "./configure", *args
    end
    system "make"
    system "make", "install"

    (share/'doc/mutt').install resource('html') if build.head?
  end
end
