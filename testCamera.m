clear vars
camera = Camera();
%camera.show()
I = camera.disp_tags();
[id, lock, pose] = camera.poses();
distance = zeros(size(pose));
p = size(pose);
for i = 1:p(2)
%get the distance from the translation matrix (if you want the x and y
%shift as well you use h(1) and h(2)
h = pose(1,i).Translation;
distance(i) = h(3);
end

