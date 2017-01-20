function mouse_move(imagefig,varargins)
global mouse_state;
global glb_handles;
global last_point;
global Seeds;
xlim = get(gca, 'XLim');
ylim = get(gca, 'YLIm');
temp = get(gca,'currentpoint');
temp = [temp(1,1), temp(1,2)];
if(temp(1)<xlim(1) || temp(1)>xlim(2) || temp(2)<ylim(1) || temp(2)>ylim(2))
    return
end
interaction_scrb = get(glb_handles.radiobutton_scrb, 'value');
if(interaction_scrb && mouse_state)
    % should draw scribbles on roi
    mouse_botton = get(gcbf, 'SelectionType');
    if(strcmp(mouse_botton,'normal')) % left mouse bottom
        hold on;
        p=plot([last_point(1), temp(1)],[last_point(2), temp(2)], 'r','MarkerSize',10);
        p(1).LineWidth = 2;
        Seeds = draw_line_on_img(Seeds, last_point, temp, 127);
    elseif(strcmp(mouse_botton,'alt')) % right mouse bottom
        hold on;
        p=plot([last_point(1), temp(1)],[last_point(2), temp(2)], 'b','MarkerSize',10);
        p(1).LineWidth = 2;
        Seeds = draw_line_on_img(Seeds, last_point, temp, 255);
    end
    last_point = temp;
end
ui_update();

function Ilab = draw_line_on_img(I, p1, p2, lab)
[H, W]=size(I);
Ilab = I;
Hdiff = abs(p2(2)-p1(2));
Wdiff = abs(p2(1)-p1(1));
if(Hdiff>Wdiff)
    step = 1.0/(Hdiff+1);
else
    step = 1.0/(Wdiff+1);
end
for i = step:step:1
    p = p1*(1.0-i)+p2*i;
    Ilab(int16(p(2)),int16(p(1)))=lab;
    if(min(H,W)>40)
        Ilab(int16(p(2)+1),int16(p(1)))=lab;
        Ilab(int16(p(2)-1),int16(p(1)))=lab;
        Ilab(int16(p(2)),int16(p(1))+1)=lab;
        Ilab(int16(p(2)),int16(p(1))-1)=lab;
    end
end

    
