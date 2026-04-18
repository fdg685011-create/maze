
function [st,t,f] = st_kdm(timeseries,minfreq,maxfreq,samplingrate,freqsamplingrate) 
    % Returns the Stockwell Transform of the timeseries. 
    % Code by Robert Glenn Stockwell. 
    % DO NOT DISTRIBUTE 
    % BETA TEST ONLY 
    % Reference is "Localization of the Complex Spectrum: The S Transform" 
    % from IEEE Transactions on Signal Processing, vol. 44., number 4, April 1996, pages 998-1001. 
    % 
    %-------Inputs Needed------------------------------------------------ 
    %   
    %   *****All frequencies in (cycles/(time unit))!****** 
    %	"timeseries" - vector of data to be transformed 
    %-------Optional Inputs ------------------------------------------------ 
    % 
    %"minfreq" is the minimum frequency in the ST result(Default=0) 
    %"maxfreq" is the maximum frequency in the ST result (Default=Nyquist) 
    %"samplingrate" is the time interval between samples (Default=1) 
    %"freqsamplingrate" is the frequency-sampling interval you desire in the ST result (Default=1) 
    %Passing a negative number will give the default ex.  [s,t,f] = st(data,-1,-1,2,2) 
    %-------Outputs Returned------------------------------------------------ 
    % 
    % st     -a complex matrix containing the Stockwell transform.  
    %			 The rows of STOutput are the frequencies and the  
    %         columns are the time values ie each column is  
    %         the "local spectrum"?????? for that point in time 
    %  t      - a vector containing the sampled times??????? 
    %  f      - a vector containing the sampled frequencies??????? 
    %--------Additional details----------------------- 
    %   %  There are several parameters???? immediately below that 
    %  the user may change. They are: 
    %[verbose]    if true prints out informational messages throughout the function. 
    %[removeedge] if true, removes a least squares fit parabola 
    %                and puts a 5% hanning taper on the edges??? of the time series. 
    %                This is usually a good idea. 
    %[analytic_signal]  if the timeseries is real-valued 
    %                      this takes the analytic signal and STs it. 
    %                      This is almost always a good idea. 
    %[factor]     the width factor of the localizing gaussian 
    %                ie, a sinusoid of period 10 seconds has a  
    %                gaussian window of width factor*10 seconds. 
    %                I usually use factor=1, but sometimes factor = 3 
    %                to get better frequency resolution. 
    %   Copyright (c) by Bob Stockwell 
    %   $Revision: 1.2 $  $Date: 1997/07/08  $ 
    TRUE = 1; 
    FALSE = 0; 
    %%% DEFAULT PARAMETERS  [change these for your particular application] 
    verbose = TRUE;           
    removeedge= FALSE; 
    analytic_signal =  FALSE; 
    factor = 1; 
    %%% END of DEFAULT PARAMETERS 

    % use defaults for input variables ???? 
%       minfreq = 0; 
%       maxfreq = fix(length(timeseries)/2); 
%       samplingrate=1; 
%       freqsamplingrate=1; 

    % calculate the sampled time and frequency values from the two sampling rates 
    t = (0:length(timeseries)-1)*samplingrate; %?????????? 
    spe_nelements =ceil((maxfreq - minfreq+1)/freqsamplingrate)   ;%????????????????????????§³???? 
    f = (minfreq + [0:spe_nelements-1]*freqsamplingrate)/(samplingrate*length(timeseries));%???????????? 
    % The actual S Transform function is here: 
    st = strans(timeseries,minfreq,maxfreq,samplingrate,freqsamplingrate,verbose,removeedge,analytic_signal,factor);  
    return 


        function st = strans(timeseries,minfreq,maxfreq,samplingrate,freqsamplingrate,verbose,removeedge,analytic_signal,factor)  
            %-------Inputs Returned------------------------------------------------ 
            %         - are all taken care of in the wrapper function above 
            % 
            %-------Outputs Returned------------------------------------------------ 
            % 
            %	ST    -a complex matrix containing the Stockwell transform. 
            %			 The rows of STOutput are the frequencies and the 
            %			 columns are the time values 
            % 
            % 
            %----------------------------------------------------------------------- 

            % Compute the length of the data. 
            n=length(timeseries); 
            % Compute FFT's 
            vector_fft0=fft(timeseries); 
            vector_fft=[vector_fft0,vector_fft0]; 
            % Preallocate the STOutput matrix ????????????? 
            st=zeros(ceil((maxfreq - minfreq+1)/freqsamplingrate),n); 
            %the actual calculation of the ST 
            % Start loop to increment the frequency point 
            for banana=freqsamplingrate:freqsamplingrate:(maxfreq-minfreq)
               st(banana/freqsamplingrate+1,:)=ifft(vector_fft(minfreq+banana+1:minfreq+banana+n).*g_window(n,minfreq+banana,factor));   

            end   
        end

    % End loop to increment???? the frequency point 


    %%% end strans function 

    %------------------------------------------------------------------------ 
        function gauss=g_window(length,freq,factor) 

        % Function to compute the Gaussion window for  
        % function Stransform. g_window is used by function 
        % Stransform. Programmed by Eric Tittley 
        % 
        %-----Inputs Needed-------------------------- 
        % 
        %	length-the length of the Gaussian window 
        % 
        %	freq-the frequency at which to evaluate??? 
        %		  the window. 
        %	factor- the window-width factor 
        % 
        %-----Outputs Returned-------------------------- 
        % 
        %	gauss-The Gaussian window 
        % 

        vector(1,:)=[0:length-1]; 
        vector(2,:)=[-length:-1]; 
        vector=vector.^2;%????????????????     
        vector=vector*(-factor*2*pi^2/freq^2);%factor?????1 
        % Compute the Gaussion window 
        gauss=sum(exp(vector));%sum(x)????????????????§Ö?????????????? 
        end
end