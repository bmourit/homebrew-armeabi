require 'formula'

class ArmNoneEabiGcc <Formula
  homepage 'https://gcc.gnu.org'
  url 'http://ftpmirror.gnu.org/gcc/gcc-7.2.0/gcc-7.2.0.tar.xz'
  mirror 'http://fr.mirror.babylon.network/gcc/releases/gcc-7.2.0/gcc-7.2.0.tar.xz'
  sha256 '1cf7adf8ff4b5aa49041c8734bbcf1ad18cc4c94d0029aae0f4e48841088479a'

  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'isl'
  depends_on 'libmpc'
  depends_on 'libelf'
  depends_on 'arm-none-eabi-binutils'
  depends_on 'gcc' => :build

  resource 'newlib' do
    url 'https://github.com/eblot/newlib-cygwin.git',
        :using => :git, :branch => 'clang-armeabi-20170818'
  end

  def install

    armnoneeabi = 'arm-none-eabi-binutils'

    coredir = Dir.pwd

    resource('newlib').stage do
      system 'ditto', Dir.pwd+'/libgloss', coredir+'/libgloss'
      system 'ditto', Dir.pwd+'/newlib', coredir+'/newlib'
    end

    gmp = Formulary.factory 'gmp'
    mpfr = Formulary.factory 'mpfr'
    libmpc = Formulary.factory 'libmpc'
    libelf = Formulary.factory 'libelf'
    isl = Formulary.factory 'isl'
    binutils = Formulary.factory armnoneeabi
    gcc = Formulary.factory 'gcc'

    # Fix up CFLAGS for cross compilation (default switches cause build issues)
    ENV['CC'] = "#{gcc.opt_prefix}/bin/gcc-?"
    ENV['CXX'] = "#{gcc.opt_prefix}/bin/g++-?"
    ENV['CFLAGS_FOR_BUILD'] = "-O2"
    ENV['CFLAGS'] = "-O2"
    ENV['CFLAGS_FOR_TARGET'] = "-O2"
    ENV['CXXFLAGS_FOR_BUILD'] = "-O2"
    ENV['CXXFLAGS'] = "-O2"
    ENV['CXXFLAGS_FOR_TARGET'] = "-O2"

    build_dir='build'
    mkdir build_dir
    Dir.chdir build_dir do
      system coredir+"/configure", "--prefix=#{prefix}", "--target=arm-none-eabi",
                  "--disable-shared", "--with-gnu-as", "--with-gnu-ld",
                  "--with-newlib", "--enable-softfloat", "--disable-bigendian",
                  "--disable-fpu", "--disable-underscore", "--enable-multilibs",
                  "--with-float=soft", "--enable-interwork", "--enable-lto",
                  "--with-multilib", "--enable-plugins",
                  "--with-abi=aapcs", "--enable-languages=c,c++",
                  "--with-gmp=#{gmp.opt_prefix}",
                  "--with-mpfr=#{mpfr.opt_prefix}",
                  "--with-mpc=#{libmpc.opt_prefix}",
                  "--with-isl=#{isl.opt_prefix}",
                  "--with-libelf=#{libelf.opt_prefix}",
                  "--with-gxx-include-dir=#{prefix}/arm-none-eabi/include",
                  "--disable-debug", "--disable-__cxa_atexit"
      # Temp. workaround until GCC installation script is fixed
      system "mkdir -p #{prefix}/arm-none-eabi/lib/fpu/interwork"
      system "make"
      system "make -j1 -k install"
    end

    ln_s "#{Formulary.factory(armnoneeabi).prefix}/arm-none-eabi/bin",
                   "#{prefix}/arm-none-eabi/bin"
  end
end

