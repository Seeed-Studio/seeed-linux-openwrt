import os
import sys
import json
import argparse
import stat
import shutil
from multiprocessing import cpu_count


ACTION = ['create', 'feeds', 'config', 'download', 'compile',
          'install', 'all', 'clean', 'distclean', 'export']


def readonly_handler(func, path, execinfo):
    os.chmod(path, stat.S_IWRITE)
    func(path)


work_dir = os.path.abspath('.')
build_dir = os.path.join(work_dir, 'build')
openwrt_dir = os.path.join(build_dir, 'openwrt')
dl_dir = None
config = None


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--build-dir', type=str, default='build')
    parser.add_argument('--dl-dir', type=str, default=None)
    parser.add_argument('--config', type=str, default='config.json')
    parser.add_argument('--action', type=str, default='', choices=ACTION)
    return parser.parse_args()


def do_create():
    print("Create openwrt project...")

    if not os.path.exists(build_dir):
        os.mkdir(build_dir)

    print("Download openwrt source code...")

    if os.path.exists(openwrt_dir):
        os.chdir(openwrt_dir)
        print("Openwrt source code already exists, try to update...")
        os.system('git clean -fd')
        os.system('git reset --hard')
        os.system('git pull')
    else:
        ret = os.system('git clone https://github.com/openwrt/openwrt -b %s %s --depth 1' %
                        (config['version'], openwrt_dir))
        if ret != 0:
            raise Exception('Download openwrt failed.')

    os.chdir(openwrt_dir)

    # copy config file
    print("Copy config file to openwrt's source code...")
    config_file = os.path.join(
        work_dir, 'openwrt', 'configs', config['config'])
    if not os.path.exists(config_file):
        print("Config file %s not found." % config_file)
        sys.exit(1)
    ret = os.system('cp -rf %s .config' %
                    os.path.join(work_dir, 'openwrt', 'configs', config['config']))
    if ret != 0:
        raise Exception('Copy config file failed.')

    # copy root file
    print("Copy root file to openwrt's source code...")
    if config['files'] != '':
        if os.path.exists('files'):
            os.system('rm -rf files')
        for file in config['files']:
            ret = os.system('cp -rf %s %s/' % (os.path.join(work_dir, 'openwrt', 'files', config['target'], config['subtarget'], file),
                                              os.path.join(openwrt_dir, 'files')))
            if ret != 0:
                raise Exception("Copy root file failed")
    else:
        print("No root file to copy.")

    # append feeds
    print("Append feeds to openwrt's source code...")
    if config['feeds'] != '':
        feeds = config['feeds']
        for feed in feeds:
            with open('feeds.conf.default', 'r') as f:
                if feed in f.read():
                    continue
            ret = os.system('echo "%s" >> feeds.conf.default' % feed)
            if ret != 0:
                raise Exception("Append feeds falied")
    else:
        print("No feeds to append.")

    # ln dl dir
    if dl_dir is not None:
        print("Link dl dir to openwrt's source code...")
        if os.path.exists('dl'):
            os.system('rm -rf dl')
        os.system('ln -sn %s dl' % dl_dir)

    # apply patches
    if config['patches'] != '':
        print("Apply patches to openwrt's source code...")
        for patch in config['patches']:
            ret = os.system('git apply %s' %
                            os.path.join(work_dir, 'openwrt', 'patches', patch))
            if ret != 0:
                raise Exception("Apply patches failed.")

    print("Setup openwrt project done.")


def do_action_hook(action):
    cur_dir = os.getcwd()
    os.chdir(openwrt_dir)
    if action != '':
        if config['action'][action] and config['action'][action] != '':
            ret = os.system(config['action'][action])
            if ret != 0:
                raise Exception("Action %s failed." % action)
    os.chdir(cur_dir)


def do_feeds():
    os.chdir(openwrt_dir)
    print("Update feeds...")
    do_action_hook('prefeeds')
    ret = os.system('./scripts/feeds update -a')
    if ret != 0:
        raise Exception("Feeds failed.")
    ret = os.system('./scripts/feeds install -a')
    if ret != 0:
        raise Exception("Feeds failed.")
    do_action_hook('postfeeds')


def do_config():
    os.chdir(openwrt_dir)
    do_action_hook('preconfig')
    ret = os.system('cp -rf %s .config' %
                    os.path.join(work_dir, 'openwrt', 'configs', config['config']))
    if ret != 0:
        raise Exception('Copy config file failed.')
    ret = os.system('make defconfig')
    if ret != 0:
        raise Exception("Config failed.")
    do_action_hook('postconfig')


def do_download():
    os.chdir(openwrt_dir)
    do_action_hook('predownload')
    ret = os.system('make download -j%d' % cpu_count())
    if ret != 0:
        # try aggin with verbose
        ret = os.system('make download -j1 V=s' % cpu_count())
        if ret != 0:
            raise Exception("Download failed.")
    do_action_hook('postdownload')


def do_compile():
    print("Do compile...")
    os.chdir(openwrt_dir)
    do_action_hook('precompile')
    ret = os.system(
        'make tools/compile -j%d || make tools/compile V=s -j1' % cpu_count())
    if ret != 0:
        raise Exception("Compile tools failed.")
    ret = os.system(
        'make toolchain/compile -j%d || make toolchain/compile V=s -j1' % cpu_count())
    if ret != 0:
        raise Exception("Compile toolchain failed.")
    ret = os.system(
        'make target/compile -j%d || make target/compile V=s -j1' % cpu_count())
    if ret != 0:
        raise Exception("Compile target failed.")
    ret = os.system(
        'make package/compile -j%d || make package/compile V=s -j1' % cpu_count())
    if ret != 0:
        raise Exception("Compile package failed.")
    do_action_hook('postcompile')


def do_install():
    print("Do install...")
    os.chdir(openwrt_dir)
    do_action_hook('preinstall')
    ret = os.system('make package/install')
    if ret != 0:
        raise Exception("Install package failed.")
    ret = os.system('make target/install')
    if ret != 0:
        raise Exception("Install target failed.")
    do_action_hook('postinstall')


def do_export():
    print("Do Export...")
    os.system("mkdir -p %s" % os.path.join(work_dir, 'bin',
              config['version'], 'targets', config['target'], config['subtarget'], config['name'].split('_')[-1]))
    os.system('cp -rf %s %s' % (os.path.join(openwrt_dir, 'bin', 'targets', config['target'], config['subtarget']), os.path.join(
        work_dir, 'bin', config['version'], 'targets', config['target'], config['subtarget'], config['name'].split('_')[-1])))


def do_clean():
    print("Do clean...")
    do_action_hook('preclean')
    ret = os.system('make clean')
    if ret != 0:
        raise Exception("Clean failed.")
    do_action_hook('postclean')


def do_upload():
    print("Do upload...")
    do_action_hook('preupload')
    print(os.getenv(''))
    do_action_hook('postupload')


if __name__ == '__main__':

    args = parse_args()

    if not os.path.isabs(args.build_dir):
        build_dir = os.path.join(work_dir, args.build_dir)
    else:
        build_dir = args.build_dir

    if args.dl_dir is not None:
        if not os.path.isabs(args.dl_dir):
            dl_dir = os.path.join(work_dir, args.dl_dir)
        else:
            dl_dir = args.dl_dir

    if args.action == 'distclean':
        if os.path.exists(build_dir):
            shutil.rmtree(build_dir, onerror=readonly_handler)
            sys.exit(0)

    if not os.path.isabs(args.config):
        args.config = os.path.join(work_dir, args.config)

    if not os.path.exists(args.config):
        print("Config file %s not found." % args.config)
        sys.exit(1)

    config = json.load(open(args.config, 'r'))

    print("Build openwrt %s" % config['version'])

    config_dump = json.dumps(config, indent=4)
    print("config: ", config_dump)

    openwrt_dir = os.path.join(build_dir, config['version'])

    try:
        if args.action == 'create':
            do_create()
        elif args.action == 'clean':
            do_clean()
        elif args.action == 'feeds':
            do_feeds()
        elif args.action == 'config':
            do_config()
        elif args.action == 'download':
            do_download()
        elif args.action == 'compile':
            do_compile()
        elif args.action == 'install':
            do_install()
        elif args.action == 'export':
            do_export()
        else:
            do_create()
            do_feeds()
            do_config()
            do_download()
            do_compile()
            do_install()
            do_export()

    except Exception as e:
        print(e)
        sys.exit(1)
