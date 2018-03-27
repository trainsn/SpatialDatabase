#coding:utf-8
import json, re, os;
from IPython.core.display import display_html, HTML, display_javascript, Javascript


class properties:
    def __init__(self, popupContent, newStyle):
        self.popupContent = popupContent
        self.newStyle = newStyle
    def to_JSON(self):
        return json.dumps(self, default=lambda o: o.__dict__)


class Feature:
    def __init__(self, geometry, popupContent, id, newStyle):
        self.type = "Feature"
        self.geometry = geometry
        self.properties = properties(popupContent, newStyle)
        self.id = id
    def to_JSON(self):
        return json.dumps(self, default=lambda o: o.__dict__)


class FeatureCollection:
    type = "FeatureCollection"
    def __init__(self):
        self.features = [] 
        
    def addFeature(self, feature):
        self.features.append(feature)
        
    def dump(self):
        if len(self.features) > 1:
            return {"type": "FeatureCollection",
                 "features":json.dumps([ob.__dict__ for ob in self.features], default=lambda o: o.__dict__)}
        else:
            return json.dumps(self.features[0], default=lambda o: o.__dict__)


def showResult(divId, lon, lat, zoom, flg = 0):
    html = ""

    if flg == 1:#display函数调用
        html ="<div id='" + divId 
        html += """' style="width: 1024px; height: 400px"></div>"""
    html += """'<link rel="stylesheet" href="tools/leaflet.css">'
        <script src="geom_display.js" type="text/javascript"></script>
        <script src="tools/leaflet.js" type="text/javascript"></script>
        <script src="tools/wkx.js" type="text/javascript"></script>
        <script src="  jsonData/""" +divId + """.json" type="text/javascript"></script>
        <script type="text/javascript"> """
    html += "display('" + divId  + "' ," + str(lon) + ", " + str(lat) + "," + str(zoom) +");</script>";
    html = html.format('')
    
    # Display in IPython notebook
    display_html(HTML(data=html))
    
def addFeature(featureCollection, results, flg):
    try:
        for result in results:
            if result.has_key('full_name'):
                featureCollection.addFeature(Feature(result['geom'], result['full_name'], result['gid'], flg))  
            elif result.has_key('name'):
                featureCollection.addFeature(Feature(result['geom'], result['name'], result['gid'], flg))
            elif result.has_key('lname'):
                featureCollection.addFeature(Feature(result['lgeom'], result['lname'], result['lgid'], flg))
            elif result.has_key('cname'):
                featureCollection.addFeature(Feature(result['cgeom'], result['cname'], result['cgid'],flg))
            elif result.has_key('hname'):
                featureCollection.addFeature(Feature(result['hgeom'], result['hname'], result['hgid'], flg))
            else:
                raise Exception('无对应的name列')
    except Exception as e:
        return False
    return True

    


def display(results, divId, lon, lat, zoom, results2 = ""):
    featureCollection = FeatureCollection()
    if addFeature(featureCollection, results, False) and addFeature(featureCollection, results2,True):

        if len(featureCollection.features) > 0:
            if os.path.exists('jsonData') == False:
                os.makedirs('jsonData')

            fd = open("jsonData/" + divId + ".json", 'w')
            words = str(featureCollection.dump())
            p = re.compile("'\[")
            words = p.sub("[", words)
            p = re.compile("]'")
            words = p.sub("]", words)
            fd.write("geometry = " + words)
            fd.close()
    
            showResult(divId, lon, lat, zoom, flg = 1)

        else:
            print "结果为空，请检查查询语句!"

        
    else:
        print   """注意输出的列名需要符合display的函数的检查规则：
         其根据name, full_name或(c/h/l)name的存在情况，分析结果中相应的gid或(c/h/l)id, geom或(c/h/l)geom列"""    


def displayAll(flg = 0):
    if flg == 1:
        showResult("map1", -28, 20, 3)
        showResult("map2", -28, 20, 3)
        showResult("map3", -28, 20, 3)
        showResult("map4", -28, 20, 3)
    
