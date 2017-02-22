clear all;
clc;
close all;


[A b]=netlist_parser();
x=A\b

V1=x(2);
V2=x(5)-x(2);
V3=x(8)-x(5);
V4=x(10)-x(8);

display([V1;V2;V3;V4])

