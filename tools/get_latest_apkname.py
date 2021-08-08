#!/usr/bin/env python3
###############################################################################
#
# about:     fetch latest f-droid repo info and parse it for a given apk
# returns:   most current apk filename
#
# author:    steadfasterX <steadfasterX | binbash - rocks>
# copyright: 2021 - steadfasterX
#
###############################################################################

import re
import xml.etree.ElementTree as ET
import requests
import argparse

xml_file = '/tmp/repoinfo.xml'

parser = argparse.ArgumentParser(description='Parsing a F-Droid repo xml to get the latest version of an APK')
parser.add_argument('--repourl', "-repourl", required=True,
                    help='The F-Droid full URI (index.xml must be in that path)')
parser.add_argument('--apkname', "-apkname", required=True,
                    help='The filename of the APK')
args = parser.parse_args()

def getXML(xmluri):
    xmlget = requests.get(xmluri)
    with open(xml_file, 'wb') as f:
        f.write(xmlget.content)

def parseXML(xmlfile, apkname):
    tree = ET.parse(xmlfile)
    root = tree.getroot()
    apkversions = []
    lver = 0

    for item in root.findall('./application/package'):
        rep_item = apkname.replace('LATEST', '.*')
        re_item = re.compile(rep_item)
        for app in item.iter('apkname'):
           if bool(re_item.match(app.text)) == True:
             #print(app.text)
             for v in item.iter('versioncode'):
               ver = int(v.text)
               #print(ver)
               if ver > lver:
                 lver = ver
    latest_apk = apkname.replace('LATEST', str(lver))
    return latest_apk

def main():
    getXML(args.repourl + "index.xml")
    parsed_apk = parseXML(xml_file, args.apkname)
    print(parsed_apk)
  
if __name__ == "__main__":
    main()
