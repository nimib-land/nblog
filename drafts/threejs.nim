import jsffi

when not defined(js):
  {.error: "This module only works on the JavaScript platform".}


type
  SceneObj* = JsObject
  PerspectiveCameraObj* = JsObject
  WebGLRendererObj* = JsObject
  MeshBasicMaterialObj* = JsObject
  GeometryObj* = JsObject
  #OptionsJs* = JsObject

proc newScene*(): SceneObj {. importcpp: "new THREE.Scene()" .}

proc newPerspectiveCamera*(a:int, b:float, c:float, d:int): PerspectiveCameraObj {. importcpp: "new THREE.PerspectiveCamera(@)" .}

proc newWebGLRenderer*(options:JsObject): WebGLRendererObj {. importcpp: "new THREE.WebGLRenderer(@)" .}

proc newBoxGeometry*(a,b,c:int): GeometryObj {. importcpp: "new THREE.BoxGeometry(@)" .}

proc newMeshBasicMaterial*(options:JsObject): MeshBasicMaterialObj {. importcpp: "new THREE.MeshBasicMaterial(@)" .}

proc newMesh*(geom:GeometryObj; material:MeshBasicMaterialObj): SceneObj {. importcpp: "new THREE.Mesh(@)" .}

proc appendRenderer*(renderer:WebGLRendererObj) {. importcpp: "document.body.appendChild(#.domElement )" .}

proc `+=`*(this:JsObject;val:float):JsObject {.importcpp:"(# += #)",discardable.}