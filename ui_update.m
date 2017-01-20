function ui_update()
global glb_handles;
global Image;
global Seeds;
global Seg;
global bounding_box_state;
global bb_p1 bb_p2;
global bb_x0 bb_x1 bb_y0 bb_y1;
if(length(size(Image))==2) % gray image
    im_show = repmat(Image, [1,1,3]);
else
    im_show = Image;
end
xlim = get(gca, 'XLim');
ylim = get(gca, 'YLIm');
currentpoint = get(gca,'currentpoint');
temp = [currentpoint(1,1), currentpoint(1,2)];

if(bounding_box_state == 1  || bounding_box_state == 2) % roi has been defined
    if(bounding_box_state==1)
        temp = [max(temp(1), xlim(1)), max(temp(2), ylim(1))];
        temp = [min(temp(1), xlim(2)), min(temp(2), ylim(2))];
        [bb_x0, bb_x1, bb_y0, bb_y1]=get_bounding_box(bb_p1, temp);
    end

%     if(~get(glb_handles.checkbox1, 'Value'))
%         im_show = addSeeds(im_show, Seeds);
%     end
end

im_show = addSeeds(im_show, Seeds);
im_show = addCountor(im_show, Seg, 'g');
cla(glb_handles.axes1,'reset');
imshow(im_show);

interaction_bb = get(glb_handles.radiobutton_bb, 'value');
if(interaction_bb)
    if(bounding_box_state == 0  || bounding_box_state == 2)
        draw_cross(xlim, ylim, temp);
    end
end
if(bounding_box_state == 1  || bounding_box_state == 2)
    % draw roi
    
    if(bounding_box_state == 1)
        draw_bounding_box(bb_x0, bb_x1, bb_y0, bb_y1, 'y');
    else
        draw_bounding_box(bb_x0, bb_x1, bb_y0, bb_y1, 'b');
    end
end    

function draw_cross(xlim, ylim, temp)

if(temp(1)>xlim(1) && temp(1)<xlim(2) && temp(2)>ylim(1) && temp(2)<ylim(2))
    X1 = [temp(1), temp(1)];
    Y1 = [ylim(1)+1, ylim(2)-1];
    X2 = [xlim(1)+1, xlim(2)-1];
    Y2 = [temp(2), temp(2)];
    hold on; plot(X1, Y1, 'y','LineWidth',2);
    hold on; plot(X2, Y2, 'y','LineWidth',2);
end

function [xmin, xmax, ymin, ymax] = get_bounding_box(p1, p2)
if(p1(1)<p2(1))
    xmin = p1(1); xmax = p2(1);
else
    xmin = p2(1); xmax = p1(1);
end

if(p1(2)<p2(2))
    ymin = p1(2); ymax = p2(2);
else
    ymin = p2(2); ymax = p1(2);
end
xmin = int16(xmin);
xmax = int16(xmax);
ymin = int16(ymin);
ymax = int16(ymax);

function draw_bounding_box(x0, x1, y0, y1, color)
leftX = [x0,x0];  leftY = [y0,y1];
hold on; plot(leftX, leftY, color,'LineWidth',2);

rightX = [x1,x1]; rightY = [y0,y1];
hold on; plot(rightX, rightY, color,'LineWidth',2);

upX = [x0, x1]; upY = [y1, y1];
hold on; plot(upX, upY, color,'LineWidth',2);

downX = [x0, x1]; downY = [y0, y0];
hold on; plot(downX, downY, color,'LineWidth',2);

function output=addCountor(rgb,seg,color)
output=rgb;
Isize=size(rgb);
Ssize=size(seg);
assert(Isize(1) == Ssize(1) && Isize(2) == Ssize(2));
if(color=='g')
    colorvector=[0 255 0];
elseif(color =='y')
    colorvector=[255 255 0];
else
    colorvector=[255 0 0];
end
for i=1:Isize(1)
    for j=1:Isize(2)
        if(i<=2 || i>=Isize(1)-1 || j<=2 || j>=Isize(2)-1)
            continue;
        end   
        if(seg(i,j)~=0 && ~(seg(i-1,j)~=0 && seg(i+1,j)~=0 && seg(i,j-1)~=0 && seg(i,j+1)~=0))
            output(i,j,1)=colorvector(1);
            output(i,j,2)=colorvector(2);
            output(i,j,3)=colorvector(3);
        end
    end
end

function output=addSeeds(rgb,seed)
Isize = size(rgb);
Ssize = size(seed);
assert(Isize(1)==Ssize(1) && Isize(2) ==Ssize(2));
for i=1:Isize(1)
    for j=1:Isize(2)
        if(seed(i,j)==127)
            rgb(i,j,:) = [255, 0, 0];
        elseif(seed(i,j)==255)
            rgb(i,j,:) = [0, 0, 255];
        end
    end
end    
output = rgb;
