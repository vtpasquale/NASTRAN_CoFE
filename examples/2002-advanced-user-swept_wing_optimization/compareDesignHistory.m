clear all; close all; clc

% read data
cofeSqp = xlsread('compareDesignHistory.xlsx','cofe');
nastran = xlsread('compareDesignHistory.xlsx','nastran');

% plot function data
figure(1)
subplot(2,1,1)
plot(cofeSqp(:,1),cofeSqp(:,2),'o-',nastran(:,1),nastran(:,2),'.-')
grid on
xlabel('Design Cycle')
ylabel('Objective Function')
legend('CoFE+SQP','Nastran')

subplot(2,1,2)
plot(cofeSqp(:,1),cofeSqp(:,3),'o-',nastran(:,1),nastran(:,3),'.-')
grid on
xlabel('Design Cycle')
ylabel('max(g)')
legend('CoFE+SQP','Nastran')