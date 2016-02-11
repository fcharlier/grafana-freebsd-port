import json
from urllib.parse import urlparse
from urllib.request import urlopen
from collections import defaultdict
from jinja2 import Environment, FileSystemLoader
from go_port_utils import parse_go_deps, github_accounts, github_projects, github_tagnames
from os.path import dirname, abspath, join, exists
from os import chdir, remove
import subprocess
import shutil
import tarfile


VERSION = '2.5.0'


home = abspath(dirname(__file__))
grafana_repo = join(home, 'grafana')
# Create the makefile

with open(join(grafana_repo, 'Godeps/Godeps.json')) as godeps_fp:
    deps = parse_go_deps(godeps_fp.read())

    env = Environment(loader=FileSystemLoader(".", "utf-8"))
    template = env.get_template('makefile.jinja2')

    with open('Makefile', 'w') as makefile:
        makefile.write(template.render(deps=deps,
                                       gh_accounts=github_accounts(deps),
                                       gh_projects=github_projects(deps),
                                       gh_tags=github_tagnames(deps)))

# Generate static assets

static_tarball = 'grafana-static-{}.tar.gz'.format(VERSION)

chdir(grafana_repo)
subprocess.run(['npm', 'install']) 
subprocess.run(['npm', 'install', '-g', 'grunt-cli']) 
subprocess.run(['grunt', 'release'])
chdir(home)
shutil.move(join(grafana_repo, 'public_gen'), join(home,'public'))
if exists(static_tarball):
    remove(static_tarball)
with tarfile.open(static_tarball, "w:gz") as tar:
    tar.add('public')
