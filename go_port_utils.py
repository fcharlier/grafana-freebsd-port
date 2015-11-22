import json
from collections import defaultdict


class GoDependency:
    import_path = None
    comment = None
    rev = None

    def __init__(self, import_path, comment, rev):
        self.import_path = import_path
        self.comment = comment
        self.rev = rev

    def __str__(self):
        return "<{}: {}>".format(self.source_name, self.name)
    
    def __repr__(self):
        return "<{} {}: {}>".format(self.__class__.__name__,
                self.source_name, self.name)
    
    @property
    def import_parts(self):
        return self.import_path.split('/')

    @property
    def dependency_path(self):
        if self.is_github:
            return "github.com/{}/{}".format(self.github_account, self.github_project)
        if self.is_golang:
            return "golang.org/x/{}".format(self.github_project)
        if self.is_gopkg:
            return self.import_path

    @property
    def project_path(self):
        return '/'.join(self.dependency_path.split('/')[:-1])

    @property
    def github_account(self):
        if self.is_github:
            return self.import_parts[1]
        if self.is_gopkg:
            return "go-"+self.import_parts[1].split('.')[0]
        if self.is_golang:
            return 'golang'

    @property
    def github_project(self):
        if self.is_github:
            return self.import_parts[2]
        if self.is_gopkg:
            return self.import_parts[1].split('.')[0]
        if self.is_golang:
            return self.import_parts[2]

    @property
    def tagname(self):
        if self.comment:
            return self.comment
        return self.rev[:7]

    @property
    def name(self):
        name = self.github_project
        name = name.replace('-','_')
        name = name.replace('.','_')
        return name
    
    @property
    def source_name(self):
        if self.is_github:
            return "github"
        if self.is_gopkg:
            return "gopkg"
        if self.is_golang:
            return "golang"

        return "UNKNOWN"


    @property
    def is_github(self):
        return self.import_path.startswith('github.com')

    @property
    def is_gopkg(self):
        return self.import_path.startswith('gopkg.in')

    @property
    def is_golang(self):
        return self.import_path.startswith('golang.org')


    @property
    def download_path(self):
        if self.import_path.startswith('github.com'):
            components = self.import_path.split('/')


def parse_go_deps(deps_json):
    _deps = {}
    for dep in json.loads(deps_json)['Deps']:
        dep = GoDependency(dep['ImportPath'], dep.get('Comment'), dep['Rev'])
        _deps[dep.github_project] = dep 

    deps = _deps.values()

    return deps


def append(port_list, item):
    lines = port_list.splitlines()
    if len(lines[len(lines)-1]) + len(item) > 68:
        port_list += "\\\n\t"
    port_list += item
    return port_list


def github_accounts(deps):
    github_accounts = defaultdict(list)

    for dep in deps:
        github_accounts[dep.github_account].append(dep.name)

    gh_accounts = "GH_ACCOUNT=\tgrafana "
    for account,_deps in github_accounts.items():
        account_name = "{}:{} ".format(account, ','.join(_deps))
        gh_accounts = append(gh_accounts, account_name)

    return gh_accounts.strip()

def github_projects(deps):
    github_project = {}

    for dep in deps:
        github_project[dep.github_project] = dep.name

    gh_projects = "GH_PROJECT=\tgrafana "
    for project, dep in github_project.items():
        gh_project = "{}:{} ".format(project, dep)
        gh_projects = append(gh_projects, gh_project)

    return gh_projects.strip()

def github_tagnames(deps):
    github_tags = {}

    for dep in deps:
        github_tags[dep.name] = dep.tagname

    gh_tags = "GH_TAGNAME=\t${DISTVERSIONPREFIX}${PORTVERSION} "
    for dep, tagname in github_tags.items():
        gh_tag = "{}:{} ".format(tagname, dep)
        gh_tags = append(gh_tags, gh_tag)

    return gh_tags.strip()
