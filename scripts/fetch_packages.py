#!/usr/bin/env python3

import os
import sys
import stat
import tempfile
import argparse
import shutil
import json

def readonly_handler(func, path, execinfo):
    os.chmod(path, stat.S_IWRITE)
    func(path)


tmp_path = ""
packages_path = ""
json_path = ""

def parse_args():

    parser = argparse.ArgumentParser(description='Fetch packages')
    parser.add_argument('--out_dir', type=str, default='/tmp/packages',
                        help='packages output path')
    parser.add_argument('--list', type=str,
                        default='packages.list', help='packages list file')

    return parser.parse_args()


def work_path(path):
    return "{}/{}".format(tmp_path, path)


def fetch():

    global tmp_path, packages_path, json_path

    tmp_path = tempfile.mkdtemp()

    with open(json_path, 'r') as load_f:
        json_dict = json.load(load_f)
        repo_url = json_dict['repo']
        repo_branch = json_dict['branch']

        if os.path.exists("{}".format(work_path(repo_branch))):
            shutil.rmtree("{}".format(work_path(repo_branch)),
                          onerror=readonly_handler)

        print(work_path(repo_branch))
        os.mkdir(work_path(repo_branch))
        os.chdir(work_path(repo_branch))
        os.system("git init")
        os.system("git checkout -b {}".format(repo_branch))
        os.system("touch README.md")
        os.system("echo \"# Welcom to Seeed's Openwrt Packages\" > README.md")
        os.system("git add README.md")
        os.system("git commit -m 'An init commit'")

        for package in json_dict['packages']:
            name = package['name']
            author = package['author']
            path = "{}/{}".format(author, name)
            package_origin = "origin-{}-{}".format(author, name)
            package_branch = "branch-{}-{}".format(author, name)
            url = package['url']
            branch = package['branch']

            try:
                if os.path.exists("{}".format(work_path(path))):
                    shutil.rmtree("{}".format(work_path(path)),
                                  onerror=readonly_handler)

                os.system(
                    "git clone {} {} -b {} --single-branch".format(url, work_path(path), branch))

            except:
                raise

            filter_path = ""

            for item in package['items']:
                if (item == "*"):
                    filter_path = "*"
                    break
                if os.path.exists("{}".format(work_path("{}/{}".format(path, item)))):
                    filter_path += " --path {}".format(item)

            if (filter_path == "*"):

                os.chdir("{}".format(work_path(format(repo_branch))))
                os.system(
                    "git remote add -f {} {}".format(package_origin, work_path(path)))
                os.system(
                    "git checkout remotes/{}/{} -b {}".format(package_origin, branch, package_branch))
                os.system("git checkout {}".format(repo_branch))
                os.system(
                    "git subtree add --prefix={}/{} {}".format(author, name, package_branch))

            elif (filter_path != ""):
                os.chdir("{}".format(work_path(path)))
                os.system("git-filter-repo {}  --force".format(filter_path))
                os.chdir("{}".format(work_path(repo_branch)))
                os.system(
                    "git remote add -f {} {}".format(package_origin, work_path(path)))
                os.system("git merge {}/{} --allow-unrelated-histories --commit -m \"merge: {}'s {}\"".format(
                    package_origin, branch, author, name))

                os.chdir("{}".format(work_path(format(repo_branch))))
                if not os.path.exists(author):
                    os.mkdir(author)
                for item in package['items']:
                    if os.path.exists("{}".format(work_path("{}/{}".format(repo_branch, item)))):
                        print("git mv {} {}/".format(item, author))
                        try:
                            os.system("git mv {} {}/".format(item, author))
                        except Exception as e:
                            print(e)

                os.system("git add --all")
                os.system(
                    "git commit -m \"{}'s {}: tidy up\"".format(author, name))

        if os.path.exists("{}".format(packages_path)):
            shutil.rmtree("{}".format(packages_path), onerror=readonly_handler)

        os.system("git clone {} {}".format(
            work_path(repo_branch), packages_path))
        os.chdir(packages_path)

        for home, dirs, files in os.walk(packages_path):
            for file in files:
                if file == 'Makefile':
                    with open(os.path.join(home, file), 'r+') as f:
                        read_data = f.read()
                        f.seek(0)
                        f.truncate()
                        write_data = read_data.replace(
                            "../../luci.mk", "$(TOPDIR)/feeds/luci/luci.mk")
                        write_data = write_data.replace(
                            "../../lang", "$(TOPDIR)/feeds/packages/lang")
                        f.write(write_data)

        os.system("git add --all")
        os.system("git commit -m \"tidy up\"")

        os.system("git remote set-url origin {}".format(repo_url))

        shutil.rmtree("{}".format(tmp_path), onerror=readonly_handler)


if __name__ == '__main__':
    args = parse_args()
    packages_path = args.out_dir
    json_path = args.list
    try:
        fetch()
    except Exception as e:
        print(e)
        if os.path.exists(tmp_path):
            shutil.rmtree(tmp_path, onerror=readonly_handler)
        sys.exit(1)
