#!/usr/bin/env python3

import os
import sys
import stat
import tempfile

try:
    import shutil
except ImportError:
    print("Installing shutil module")
    res = os.system("pip3 install shutil")
    if res != 0:
        print("shutil module installation failed")
        sys.exit(1)
    import shutil


try:
    import json
except ImportError:
    print("Installing json module")
    res = os.system("pip3 install json")
    if res != 0:
        print("json module installation failed")
        sys.exit(1)
    import json


def readonly_handler(func, path, execinfo):
    os.chmod(path, stat.S_IWRITE)
    func(path)


tmp_path = ""
packages_path = ""
json_path = ""

def work_path(path):
    return "{}/{}".format(tmp_path, path)


def main():

    global tmp_path

    tmp_path = tempfile.mkdtemp()
  
    with open(json_path, 'r') as load_f:
        json_dict = json.load(load_f)
        repo_url = json_dict['repo']
        repo_branch = json_dict['branch']

    
        if os.path.exists("{}".format(work_path(repo_branch))):
            shutil.rmtree("{}".format(work_path(repo_branch)),onerror=readonly_handler)

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
            path = "{}/{}".format(author,name)
            package_origin = "origin-{}-{}".format(author, name)
            package_branch = "branch-{}-{}".format(author, name)
            url = package['url']
            branch = package['branch']

            try:
                if os.path.exists("{}".format(work_path(path))):
                    shutil.rmtree("{}".format(work_path(path)), onerror=readonly_handler)

                os.system("git clone {} {} -b {} --single-branch".format(url, work_path(path), branch))

            except:
                raise

            filter_path = ""

            for item in package['items']:
                if(item == "*"):
                    filter_path = "*"
                    break
                if os.path.exists("{}".format(work_path("{}/{}".format(path, item)))):
                    filter_path += " --path {}".format(item)
            
            if(filter_path == "*"):
               
                os.chdir("{}".format(work_path(format(repo_branch))))
                os.system("git remote add -f {} {}".format(package_origin, work_path(path)))
                os.system("git checkout remotes/{}/{} -b {}".format(package_origin, branch, package_branch))
                os.system("git checkout {}".format(repo_branch))
                os.system("git subtree add --prefix={}/{} {}".format(author,name, package_branch))

            elif(filter_path != ""):
                os.chdir("{}".format(work_path(path)))
                os.system("git-filter-repo {}  --force".format(filter_path))
                os.chdir("{}".format(work_path(repo_branch)))
                os.system("git remote add -f {} {}".format(package_origin, work_path(path)))
                os.system("git merge {}/{} --allow-unrelated-histories --commit -m \"merge: {}'s {}\"".format(package_origin, branch, author, name))
            
                os.chdir("{}".format(work_path(format(repo_branch))))
                os.mkdir(author)
                for item in package['items']:
                    if os.path.exists("{}".format(work_path("{}/{}".format(repo_branch, item)))):
                        print("git mv {} {}/".format(item, author))
                        try:
                            os.system("git mv {} {}/".format(item, author))
                        except Exception as e:
                            print(e)

                os.system("git add --all")
                os.system("git commit -m \"{}/{}: tidy up\"".format(author, name))

        if os.path.exists("{}".format(packages_path)):
            shutil.rmtree("{}".format(packages_path), onerror=readonly_handler)

        os.system("git clone {} {}".format(work_path(repo_branch), packages_path))
        os.chdir(packages_path)
        os.system("git remote set-url origin {}".format(repo_url))

        #shutil.rmtree("{}".format(tmp_path), onerror=readonly_handler)


if __name__ == '__main__':

    if(len(sys.argv) <= 1):
        packages_path = "/tmp/packages"
        json_path = "./scripts/packages.json"
    elif(len(sys.argv) <= 2):
        packages_path = "/tmp/packages"
        json_path = sys.argv[1]
    else:
        json_path = sys.argv[1]
        packages_path = sys.argv[2]
    try:
        main()
    except:
        if os.path.exists(tmp_path):
            shutil.rmtree(tmp_path, onerror=readonly_handler)
