function mouse_down(imagefig,varargins)
global glb_handles;
global bounding_box_state;
global mouse_state;
global bb_p1;
global bb_p2;
global last_point;
xlim = get(gca, 'XLim');
ylim = get(gca, 'YLIm');
temp = get(gca,'currentpoint');
if(temp(1,1)<xlim(1) || temp(1,1)>xlim(2) || temp(1,2)<ylim(1) || temp(1,2)>ylim(2))
    return;
end
interaction_bb = get(glb_handles.radiobutton_bb, 'value');
if(interaction_bb)
    if(bounding_box_state==0 || bounding_box_state==2)
        bb_p1 = [temp(1,1), temp(1,2)];
        bounding_box_state=1;
    else
        bb_p2 = [temp(1,1), temp(1,2)];
        bounding_box_state=2;
        set(glb_handles.radiobutton_scrb, 'value',1);
    end
end
mouse_state=1;
last_point = [temp(1,1), temp(1,2)];