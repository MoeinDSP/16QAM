clc;
clear all; 
close all;
input = randi([0 1],1,80000);%Producing Intial Binary Inputs Making Samples
input_s=zeros(1,20000); %Converting Input Bits to Samples
output=zeros(1,80000); %Binary Bits After Crossing The Channel 
Eb_N0_dB = [0:10]; %We wanna find BER from 0dB to 10dB 
nn = 0; %As a counter in the while loop in Modulation(Signal Trasnmision)
a=0; %As  a variable in our modulation
err_num=0;%Num Error
Eb = 6; %The Energy of Bits
%% signal transmision and detection 
%We Wanna Make a Modulation for converting the bits to Symbols By loop.
%I used gray code for modulating.
while nn<length(input_s)
    nn=nn+1;
    mm=4*nn;% each 4 bits convert to a symbol.
%% This part related to Real Part in Gray Code  
if input(1,mm-3)==0&&input(1,mm-2)==0
    a = a+(1*sqrt(Eb/2.5));
end
if input(1,mm-3)==0&&input(1,mm-2)==1
   a = a+(3*sqrt(Eb/2.5));
end

if input(1,mm-3)==1&&input(1,mm-2)==0
    a = a-(1*sqrt(Eb/2.5));
end
if input(1,mm-3)==1&&input(1,mm-2)==1
    a = a-(3*sqrt(Eb/2.5));
end
%% this part realated to Image part in Gray code
if input(1,mm-1)==0&&input(1,mm)==0
    a=a+(1*j*sqrt(Eb/2.5)); %Real = +3 
end
if input(1,mm-1)==0&&input(1,mm)==1
  a=a+(3*j*sqrt(Eb/2.5)); %Real = +1 
end

if input(1,mm-1)==1&&input(1,mm)==0
    a=a-(1*j*sqrt(Eb/2.5));  %Real = -1
end
if input(1,mm-1)==1&&input(1,mm)==1
    a=a-(3*j*sqrt(Eb/2.5)); %Real = -3
end
 input_s(nn) = a;
 
 a=0;
end
%% Denodulation 
SimBer=zeros(1,length(Eb_N0_dB));%we should make 10 bits rate for SNR 0dB to 10dB
%We have 80000 bits that we wanna contribute them between 10 different types of SNR(Eb/N0) 
for iii=1:length(Eb_N0_dB)
    N0=Eb/(10^(Eb_N0_dB(iii)/10)); %for making 10 different N0
    white=sqrt(N0/2)*(randn(1,20000)+j*randn(1,20000));
    input_s_reciever =  input_s + white;
    for ii=1:20000 %for converting symbol to bit
        n=4*ii; 
        if (real(input_s_reciever(ii)))>=(2*sqrt(Eb/2.5))
            output(n-2)=1;
            output(n-3)=0;
            %Real +3 
        end
        if (real(input_s_reciever(ii)))<(-2*sqrt(Eb/2.5))
            output(n-2)=1;
            output(n-3)=1;
            %Real -3
        end
        if (real(input_s_reciever(ii)))>=0 && (real(input_s_reciever(ii)))<(2*sqrt(Eb/2.5))
            output(n-2)=0;
            output(n-3)=0;
            %Real +1
        end
        if (real(input_s_reciever(ii)))>=(-2*sqrt(Eb/2.5)) && (real(input_s_reciever(ii)))<0
            output(n-2)=0;
            output(n-3)=1;
            %real -1
        end
        %%
        if (imag(input_s_reciever(ii)))>=(2*sqrt(Eb/2.5))
            output(n)=1;
            output(n-1)=0;
            %Image +3
        end
        if (imag(input_s_reciever(ii)))<(-2*sqrt(Eb/2.5))
            output(n)=1;
            output(n-1)=1;
            %Image -3
        end
        if (imag(input_s_reciever(ii)))>=0 && (imag(input_s_reciever(ii)))<(2*sqrt(Eb/2.5))
            output(n)=0;
            output(n-1)=0;
            %Image +1
        end
        if (imag(input_s_reciever(ii)))>=(-2*sqrt(Eb/2.5)) && (imag(input_s_reciever(ii)))<0
            output(n)=0;
            output(n-1)=1;
            %Image -1
        end
%% Error Part 
        if input(n) ~= output(n)
            err_num = err_num + 1;
         end
        if input(n-1) ~= output(n-1)
                err_num = err_num + 1;
          end
        if input(n-2) ~= output(n-2)
                err_num = err_num + 1;
          end
        if input(n-3) ~= output(n-3)
                err_num = err_num + 1;
          end
        
    
    end
    SimBer(iii)=(err_num)/80000;
    err_num = 0;
end   
Eb_N0_Theory=0:10;
BER_value_Theory=berawgn(Eb_N0_Theory,'qam',16);
semilogy(Eb_N0_dB,SimBer,'-or',Eb_N0_Theory,BER_value_Theory,'-ok','LineWidth',1.25);
legend('simulation','theory');
xlabel('Eb/No, dB')
ylabel('BER');



        
        
        
