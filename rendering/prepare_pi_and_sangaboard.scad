use <../openscad/libs/lib_microscope_stand.scad>
use <./librender/render_utils.scad>
use <./electronics/sangaboard.scad>
use <./librender/electronics.scad>

FRAME = 3;

prepare_pi_and_sangaboard(FRAME);

module prepare_pi_and_sangaboard(frame){
    if (frame == 1){
        pi_and_sd_card(exploded=true);
    }
    if (frame == 2){
        pi_and_sd_card(exploded=false);
    }
    if (frame == 3){
        sangaboard_v0_5();
    }
}

module pi_and_sd_card(exploded=false){
    rpi_4b();
    place_part(place_micro_sd_card(exploded=exploded)){
        micro_sd_card();
    }
}

function place_micro_sd_card(exploded=false) = let(
    size_y = (pi_board_dims().y / 2) - 0.65 ,
    explode = exploded ? [-20,0,0] : [0,0,0]
)    create_placement_dict(translation=[-2.5,size_y,-0.5]+explode, rotation2=[180,0,0], rotation1=[0,0,-90]);
