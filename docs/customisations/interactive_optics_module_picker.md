# RMS Optics module picker

<form id="opticsModuleSelectorForm">
    <b><label for="cameraSelector">Camera: </label></b><br />
    <select name="camera" id="cameraSelector" oninput="updateOpticsModuleLink()" >
        <option value="picamera_2">Raspberry Pi camera module, version 2</option>
        <option value="m12">Board camera with M12 lens</option>
        <option value="logitech_c270">Logitech C270 webcam</option>
    </select>
    <br /><br />
  <b><label for="objectiveSelector">Objective: </label></b><br />
    <select name="objective" id="objectiveSelector" oninput="updateOpticsModuleLink()" >
        <option value="rms">RMS threaded, finite conjugates (160mm tube length) objective with 45mm parfocal distance.</option>
        <option value="rms_infinity">RMS threaded, infinity corrected objective with 45mm parfocal distance.</option>
    </select>
    <br /><br />
    <input type="checkbox" name="beamsplitter" id="beamsplitterCheckbox" value="yes" oninput="updateOpticsModuleLink()" />
    <b><label for="beamsplitterCheckbox">Include beamsplitter cut-out.</label></b>
   <br /><br />
   <b>Chosen optics module:</b>
   <br />
        <code><a id="opticsModuleSelectorLink" href="">Select options to generate a filename</a></code> 
        <span id="tallStandWarning"></span>
</form>

<script type="text/javascript">
//<![CDATA[
function getRadioValue(name){
    let options = document.getElementsByName(name);
    for(i=0; i < options.length; i++){
        if(options[i].checked){
            return options[i].value;
        }
    }
    return false;
}
function updateOpticsModuleLink(){
    let camera = document.getElementById("cameraSelector").value;
    let objective = document.getElementById("objectiveSelector").value;
    let beamsplitter = document.getElementById("beamsplitterCheckbox").checked ? "_beamsplitter" : "";
    let tubelens = "f50d13"
    if(camera && objective){
        let link = document.getElementById("opticsModuleSelectorLink");
        let basename = "optics_" + camera + "_" + objective + "_" + tubelens + beamsplitter;
        link.innerHTML = basename + ".stl";
        link.href = "../models/" + basename + ".html";
        let warning = document.getElementById("tallStandWarning");
        if(objective=="rms_infinity"){
            warning.innerHTML = "<b>Requires tall microscope stand</b> (see below).";
        }else{
            warning.innerHTML = "";
        }
    }
}
updateOpticsModuleLink(); // Set the initial value
//]]>
</script>