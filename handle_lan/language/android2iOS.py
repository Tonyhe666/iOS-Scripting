#!/usr/bin/python
# -*- coding: UTF-8 -*-


# ------------------------android 的xml语言文件解析------------------------------

from xml.dom import minidom

def get_attrvalue(node, attrname):
     return node.getAttribute(attrname) if node else ''

def get_nodevalue(node, index = 0):
	child = node.firstChild
	if child :
		return child.nodeValue
	else :
		return ''
   # return node.childNodes[index].nodeValue if node else ''

def get_xmlnode(node,name):
    return node.getElementsByTagName(name) if node else []

def xml_to_string(filename='strings.xml'):
    doc = minidom.parse(filename)
    return doc.toxml('UTF-8')

def get_xml_data(filename='strings.xml'):
    doc = minidom.parse(filename) 
    root = doc.documentElement
    name_nodes = get_xmlnode(root, 'string')
    dic = {}
    for node in name_nodes:
    	key = get_attrvalue(node, 'name')
    	#print key
    	value = get_nodevalue(node).encode('utf-8', 'ignore')
    	#print value
    	dic[key] = value
    	#print key
    	#print dic[key]
    return dic


# ------------------------iOS 语言文件解析------------------------------
def findKey(line):
	index = line.find('=')
	#print index
	if index != -1:
		strkey = line[0:index] # not include =
		#print strkey
		return strkey.encode('utf-8', 'ignore')
	else:
		return ''

def get_Infoplist_data(name='InfoPlist.strings'): 
	key_list = []
	fp = open(name, 'r')
	for eacheline in fp:
		#print eacheline
		key = findKey(eacheline)
		if key != '' :
			key_list.append(key)
	fp.close
	return key_list


# 生成新的语言文件
def generalInfoplist(android_map, iOS_list):
	fp = open('newiOS.strings', 'wb')
	for key in iOS_list:
		value =  android_map.get(key)
		if value != None:
			str = "%s=\"%s\";\n" % (key, value)
			fp.writelines(str)
	fp.close


# xml 转infoplist
def xml2infoplist(android_map):
	fp = open('dic.strings', 'wb')
	for key in android_map:
		str = "%s=\"%s\";\n" % (key, android_map[key]) 
		fp.writelines(str)
	fp.close
		




if __name__ == "__main__": 
	android_map = get_xml_data()
	xml2infoplist(android_map)
	iOS_list = get_Infoplist_data()
	generalInfoplist(android_map, iOS_list)


	

