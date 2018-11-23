%Ronny


my_y = [0:1:100];

my_x = my_y.^2;

plot(my_y,my_x)

hgexport_script('small_low_res_png.png', 5, 3, 10,500,'png')
hgexport_script('large_high_res_pdf.png', 15, 15, 20,1000,'png')