require "formula"

class Muttprint < Formula
  homepage "http://muttprint.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/muttprint/muttprint/muttprint-0.73/muttprint-0.73.tar.gz"
  sha1 "75a02707c8a6f84d926952edcd246bd2a9e5e848"

  def install
    system "make", "-B", "prefix=#{prefix}", "docdir=#{share}/doc/packages/", "install"
  end

  test do
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "muttprint"
  end
end
