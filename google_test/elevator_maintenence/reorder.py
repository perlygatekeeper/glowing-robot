from operator import itemgetter
def solution(l):
    version_list = []
    for version in l:
        versions = {'major':None, 'minor':None, 'revision':None}
        component = 'major'
        for i in version.split('.'):
            versions[component] = int(i)
            if component == 'major':
                component = 'minor'
            elif component == 'minor':
                component = 'revision'
        print versions;
        # -1 because it will then sort before 0, so 2 will come before 2.0
        # in other words a version with minor not specified will appear before one with minor = 0
        if versions['revision'] == None:
            versions['revision'] = -1
            if versions['minor'] == None:
                versions['minor'] = -1
        version_list.append(versions)
    # first sort by major then minor and finally revision
    version_list.sort(key=itemgetter('major','minor','revision'))
    sorted_versions = []
    for version in version_list:
        new_str = str(version['major'])
        if version['minor'] != -1:
            new_str += "." + str(version['minor'])
            if version['revision'] != -1:
                new_str += "." + str(version['revision'])
        sorted_versions.append(new_str)
    return sorted_versions

l = ["1.11", "2.0.0", "1.2", "2", "0.1", "1.2.1", "1.1.1", "2.0"]
print(l)
print solution(l)

l = ["1.1.2", "1.0", "1.3.3", "1.0.12", "1.0.2"]
print(l)
print solution(l)
