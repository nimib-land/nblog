import nimib

nbInit
nb.partials["head"] &= """<script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r83/three.min.js"></script>"""
nbJsFromCode:
  # nim js ex01
  import jsffi, std/dom
  import threejs

  # Create an empty scene
  var scene = newScene()

  # Create a basic perspective camera

  var tmp = clientWidth().float / clientHeight().float
  var camera = newPerspectiveCamera( 75, tmp, 0.1, 1000 )
  camera.position.z = 4

  # Create a renderer with Antialiasing
  var antialias = newJsObject()
  antialias["antialias"] = true
  var renderer = newWebGLRenderer(antialias)

  # Configure renderer clear color
  renderer.setClearColor("#000000".cstring)

  # Configure renderer size
  renderer.setSize( clientWidth(), clientHeight() )


  # Append Renderer to DOM
  appendRenderer( renderer )

  # ------------------------------------------------
  # FUN STARTS HERE
  # ------------------------------------------------

  # Create a Cube Mesh with basic material
  var geometry = newBoxGeometry( 1, 1, 1 )
  var color = newJsObject()
  color["color"] = "#433F81".cstring
  var material = newMeshBasicMaterial( color )
  var cube = newMesh( geometry, material )

  # Add cube to Scene
  scene.add( cube )


  # Render Loop
  #echo cube.rotation.x
  proc render(time:float) = 
    discard window.requestAnimationFrame( render )
    cube.rotation.x += 0.01
    cube.rotation.y += 0.01

    # Render the scene
    renderer.render(scene, camera)

  render(0.0)

nbSave




