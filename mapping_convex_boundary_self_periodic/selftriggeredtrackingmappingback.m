N=6; %the number of sensor agents 
T=0.1; % sampling period
max_step=800;
omega_max=1; %maximum angular velocity for each sensor agent
error_mat = zeros(1, max_step);
delta=0.06;

px=zeros(N,max_step);
py=zeros(N,max_step);

itheta=zeros(N,max_step); %locations of all agents at all timesteps 
theta=zeros(N+2,max_step);
phi=zeros(N,max_step);%relative angular distance
P=zeros(N,max_step); %communicaiton power
Con=zeros(N,max_step); % convergence speed
gVimid=zeros(N,max_step); %the midepoint of i's guaranteed Voronoi set
u=zeros(N,max_step);

itheta(:,1)=[69.8979;75.0730;83.1024;108.1016;170.1016;303.8982];
%itheta(:,1)=round(sort(360*rand(N,1)));% initial locations of six sensor agents, counterclosewise order
%temptheta=round(sort(360*rand(N,1)));
%itheta(:,1)=temptheta;

% itheta(:,1) = [
%    102
%    124
%    168
%    179
%    199];
Tar=[4;20];% jointed positions and the target



for i=1:N
    %itheta(i,1)=positiontoangularfun(py(i,1)-20,px(i,1)-4);
    [px(i,1),py(i,1)]=angulartopositionfun(itheta(i,1),Tar(1,1),Tar(2,1));
end

theta(:,1)=[(itheta(N,1)-360);itheta(:,1);(itheta(1,1)+360)]; %virtual agent 0th:=agent N-2pi;virtual agent 7th:=agent 1st+ 2pi

R=zeros(2*N, max_step); %information agent keeps for its neighbors
for i=1:N
    R(2*i-1:2*i,2)=[theta(i,1);(theta(i+2,1))];
    utemp=1/4*(theta(i+2,1)-2*theta(i+1,1)+theta(i,1));
    %pretemp(i,1)=sign(utemp);
    u(i,1)=sign(utemp)*min(omega_max,abs(utemp));
    %itheta(i,2)=itheta(i,1)+1/4*T*(theta(i+2,1)-2*theta(i+1,1)+theta(i,1));% at the initial step, agent knows the exact info. of its meihhbors.
    itheta(i,2)=itheta(i,1)+T*u(i,1);
   
    %/********/target input-----------
    [px(i,2),py(i,2)]=angulartopositionfun(itheta(i,2),Tar(1,1),Tar(2,1));
     %itheta(i,2)=itheta(i,1)+1/4*T*(theta(i+2,1)-2*theta(i+1,1)+theta(i,1));% at the initial step, agent knows the exact info. of its meihhbors.
     gVimid(i,1)=1/4*(theta(i+2,1)+2*theta(i+1,1)+theta(i,1));
     Con(i,1)=abs(itheta(i,1)-gVimid(i,1));
end
theta(:,2)=[(itheta(N,2)-360);itheta(:,2);(itheta(1,2)+360)];

C=zeros(N,max_step);%communication record;
C(:,1)=1;
count=ones(N,1);


for k=2: max_step
   
    for i=1:N
         
          ubdi=omega_max*T*count(i)/2; %upper bound
          r=omega_max*T*count(i); % the prediciton range of neighbors' motion
          gVimid(i,k)=1/4*(R(2*i,k)+2*itheta(i,k)+R(2*i-1,k)); % the midepoint of i's guaranteed Voronoi set 
          Con(i,k)=abs(itheta(i,k)-gVimid(i,k));
          
          errp=gVimid(i,k)-itheta(i,k); 
          abserrp=abs(gVimid(i,k)-itheta(i,k));
          proximity=max(abserrp,delta); % the degree agent goes towards midpoint of its guaranteed Voronoi set
         
          if ((ubdi>=proximity)||(R(2*i,k)-r<=itheta(i,k))||(R(2*i-1,k)+r>=itheta(i,k)))
          %if (ubdi>=proximity)    
             R(2*i-1:2*i,k+1)=[theta(i,k);(theta(i+2,k))];% update the stored memory of its neighbors
             C(i,k)=1;%if couumicaiton occurs, set the flag 1
             count(i)=1; % reset the number of omega*T
           
             %itheta(i,k+1)=itheta(i,k)+1/4*T*(theta(i+2,k)-2*theta(i+1,k)+theta(i,k));
             utemp=1/4*(theta(i+2,k)-2*theta(i+1,k)+theta(i,k));
             u(i,k)=sign(utemp)*min(omega_max,abs(utemp));
             itheta(i,k+1)=itheta(i,k)+T*u(i,k);
            [px(i,k+1),py(i,k+1)]=angulartopositionfun(itheta(i,k+1),Tar(1,1),Tar(2,1));
          else
              
             R(2*i-1:2*i,k+1)=R(2*i-1:2*i,k); %keep memory
             count(i)=count(i)+1;
             
                 if (abserrp>=ubdi+omega_max*T)
                 itheta(i,k+1)=itheta(i,k)+T*omega_max*errp/abserrp;
                  [px(i,k+1),py(i,k+1)]=angulartopositionfun(itheta(i,k+1),Tar(1,1),Tar(2,1));
                 elseif (abserrp<=ubdi)
                 itheta(i,k+1)=itheta(i,k);
                  [px(i,k+1),py(i,k+1)]=angulartopositionfun(itheta(i,k+1),Tar(1,1),Tar(2,1));
                 else
                 itheta(i,k+1)=itheta(i,k)+T*(abserrp-ubdi)/T*errp/abserrp; 
                  [px(i,k+1),py(i,k+1)]=angulartopositionfun(itheta(i,k+1),Tar(1,1),Tar(2,1));
                 end
                 
          end    
               
     end
    theta(:,k+1)=[(itheta(N,k+1)-360);itheta(:,k+1);(itheta(1,k+1)+360)];
    
    % Plot the robots
    subplot(2,2,1)
    title('Unit Circle','fontsize',12)
    xlabel({'$$x$$'},'Interpreter','latex','fontsize',14)
    ylabel({'$$y$$'},'Interpreter','latex','fontsize',14)
     cla; hold on; axis equal
    th = 0 : 0.1 : 2*pi;
    cx = cos(th); cy = sin(th);
    plot(cx,cy,'--');
    
    for i = 1 : size(itheta,1)
        plot(0,0,'*');hold on
        plot(cos(deg2rad(itheta(i,k))), sin(deg2rad(itheta(i,k))),'ro','MarkerFaceColor','r'); hold on
        plot ([cos(deg2rad(itheta(i,k))) 0], [sin(deg2rad(itheta(i,k))) 0],':')
    end
    pause(0.01);
    
 subplot(2,2,2)
 title('Polygon','fontsize',12)
    xlabel({'$$x$$'},'Interpreter','latex','fontsize',14)
    ylabel({'$$y$$'},'Interpreter','latex','fontsize',14)
% figure(2); 
cla; hold on;axis equal
%plot the boundary
x1=3:0.1:8;
y1=2*x1+1; %line 1
plot(x1,y1)
hold on

x2=5:0.1:8;
y2=-3*x2+41; %line 2
%  figure(2);
plot(x2,y2) 
hold on

x3=1:0.1:5;
y3=x3+21; %line 3
%  figure(2);
plot(x3,y3) 
hold on 

x4=1:0.1:3;
y4=-7.5*x4+29.5; %line 4
%  figure(2);
plot(x4,y4)
hold on
 
% figure(2);
plot(4,20,'*'), hold on

    for i = 1 : size(itheta,1)
%        figure(2);
        plot(px(i,k), py(i,k),'ro','MarkerFaceColor','r');
        plot ([px(i,k) Tar(1,1)], [py(i,k) Tar(2,1)],':')
    end
    pause(0.01);
    
  
    subplot(2,2,[3,4])
    title('Self-triggered tracking with a stationary target','fontsize',14)
    xlabel({'$$k$$'},'Interpreter','latex','fontsize',14)
    %ylabel({'$$y$$'},'Interpreter','latex','fontsize',14)
    ylabel('Convergence','fontsize',14)
%     figure(1); 
    
    %cla;
 % axis equal
  %  plot(1000,0);
    cla;hold on;
    plot(800, 65);
    hold on;
    
    plot(800, 0);
    hold on;
    error_mat(1,k) = sum(Con(:,k));
    plot(2:k, error_mat(:,2:k),'r');
    
    %if mod(i,4)==0, % Uncomment to take 1 out of every 4 frames.
        frame = getframe(gcf); % 'gcf' can handle if you zoom in to take a movie.
        writeVideo(writerObj, frame);
    %end
    
 end
hold  off
