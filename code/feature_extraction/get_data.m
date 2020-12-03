hrt_dir_struct = dir('**/HRT*');
hrt_table = struct2table(hrt_dir_struct);
%filter hrt zero byte
hrt_table = hrt_table(hrt_table.bytes>0,:);
folder_names = hrt_table.folder;
device_idx = cellfun(@(x) strsplit(x,'/'),folder_names, 'UniformOutput',false);
device_idx = cellfun(@(x) x{7},device_idx,'UniformOutput',false);
device_idx = cell2table(device_idx);
hrt_table = [hrt_table device_idx];

timestamp = hrt_table.name;
timestamp = cellfun(@(x) strsplit(x,'_'),timestamp,'UniformOutput',false);
timestamp = cellfun(@(x) strsplit(x{2},'.'),timestamp,'UniformOutput',false);
timestamp = cellfun(@(x)  str2num(x{1}),timestamp,'UniformOutput',false);
timestamp = cell2table(timestamp);
hrt_table = [hrt_table timestamp];


e4_id = {'A020B9';'A01B22';'A019A8';'A021AD'};
e4_id_n = [1;2;3;4] ;
e4_vs_id = table(e4_id_n,'RowNames',e4_id);
ibi_dir_struct = dir('**/IBI*');
ibi_table = struct2table(ibi_dir_struct);
%filter hrt zero byte
ibi_table = ibi_table(ibi_table.bytes>0,:);
folder_names = ibi_table.folder;
device_idx = cellfun(@(x) strsplit(x,'/'),folder_names, 'UniformOutput',false);
device_idx = cellfun(@(x) x{end},device_idx,'UniformOutput',false);
tmp = cellfun(@(x) strsplit(x,'_'),device_idx, 'UniformOutput',false);
device_idx = cellfun(@(x) x{end},tmp,'UniformOutput',false);
timestamp =  cellfun(@(x) x{1},tmp,'UniformOutput',false);
device_idx = cell2table(device_idx);
timestamp =   str2num(cell2mat(timestamp))*1000;
timestamp = array2table(timestamp);
ibi_table = [ibi_table device_idx timestamp];


session_infos = readtable('Information_tables/Session_start_end.csv');
start_timestamp = posixtime(datetime(session_infos.Start,'InputFormat','dd.MM.yyyy HH:mm','TimeZone','Europe/Istanbul'));
end_timestamp = posixtime(datetime(session_infos.End,'InputFormat','dd.MM.yyyy HH:mm','TimeZone', 'Europe/Istanbul'));
session_infos = [session_infos array2table(start_timestamp) array2table(end_timestamp)];

hrt_table = [hrt_table;ibi_table];
hrt_ts = hrt_table.timestamp;
for c= 1:height(session_infos)
      %get current session
      cs = session_infos(c,:);
      s = hrt_ts/1000>= (cs.start_timestamp-45*60 ) & hrt_ts/1000<= cs.end_timestamp;
      %get session tables
      session_tables{c} = hrt_table(s,:);
end



subject_device = readtable('Information_tables/device_subject_id.csv');



my_infos = dir('Information_tables/*');
my_infos = struct2table(my_infos);
feature_vector = [];
my_feature = [];
table_size = size(session_tables);
session_table_height = table_size(2);
for c = 1:session_table_height
        cs = session_tables{c};
        sname = session_infos(1,1);
        %discard S3s 
        %cs = cs(~contains(cs.device_idx,'S3'),:);
        for(i=1:height(cs))
            %current record
            myIBI = [];
            cd = cs(i,:);
            %each device has device id for example S2_1 has device id 1
            splitted_id = strsplit(cell2mat(cd.device_idx),'_');
            device_id = splitted_id(end);
            if(contains(cd.device_idx,'S2222'))
            hrt_name = cell2mat(strcat(cd.folder,'/','HRT_',cd.timestamp,'.txt'));
            acc_name = cell2mat(strcat(cd.folder,'/','ACC_',cd.timestamp,'.txt'));
            lgt_name = cell2mat(strcat(cd.folder,'/','LGT_',cd.timestamp,'.txt'));
            IBI = readtable(hrt_name);
            ACC = readtable(acc_name);
            LGT = readtable(lgt_name);
            %clear zero RR
            IBI = IBI(table2array(IBI(:,3))>0,:);
            IBI_a = table2array(IBI);                       
            myIBI(:,1) = cumsum(IBI_a(:,3))/1000;
            myIBI(:,2) = IBI_a(:,3)/1000;
            myIBI = vertcat([0 myIBI(1,2)],myIBI);
            IBI_ts = IBI_a(:,1);
            start = IBI_ts(1);
            my.end = IBI_ts(end);
            total_time = myIBI(end,1);
            interval=120;
            ACC = table2array(ACC);
            ACC_n = ACC(ACC(:,1)>=start & ACC(:,1)<=my.end ,:);
            mean_acc_mag = [];
            mean_acc_x = [];
            mean_acc_y = [];
            mean_acc_z = [];
            energy = [];
            ACC_n(:,1) = (ACC_n(:,1)-start)/1000;
            for count =1:0.5:total_time/interval
               y = ACC_n(find(ACC_n(:,1)>interval*(count-1) & ACC_n(:,1)<interval*count),:);
               z = sqrt(y(:,3).^2 +y(:,4).^2 + y(:,5).^2);
               energy = vertcat(energy,sum(abs(fft(z)))/length(z));
               mean_acc_mag = vertcat(mean_acc_mag,mean(z));
               mean_acc_x = vertcat(mean_acc_x,mean(y(:,3)));
               mean_acc_y = vertcat(mean_acc_y,mean(y(:,4)));
               mean_acc_z = vertcat(mean_acc_z,mean(y(:,5)));
               meac_acc_z_g = vertcat(mean_acc_z,mean(y(:,8)));
            end

            [fft_pLF,fft_pHF,fft_LFHFratio,fft_VLF,fft_LF,fft_HF,lomb_lf,RMSSD,PNN50,TRI,TINN,lomb_hf,meanV,stdV,sdsd,qr,peakpersecond] = FilterInterpolateWithSeconds(myIBI,0.2,6,10);
            my_l = length(fft_pLF);
            session_id = c;
            my_feature = horzcat(fft_pLF,fft_pHF,fft_LFHFratio,fft_VLF,fft_LF,fft_HF,lomb_lf,lomb_hf,RMSSD,PNN50,TRI,TINN,lomb_lf./lomb_hf,meanV,stdV,sdsd,mean_acc_mag,mean_acc_x,mean_acc_y,mean_acc_z,energy,qr,ones(my_l,1)*2,ones(my_l,1)*table2array(e4_vs_id(cell2mat(device_id),1)),ones(my_l,1)*session_id);
            feature_vector = vertcat(feature_vector,my_feature);

            end
            if(contains(cd.device_idx,'S'))
            end
            if(contains(cd.device_idx,'S3'))
            
            end
            %E4
           
            if(contains(cd.device_idx,'A0'))
            hrt_name = cell2mat(strcat(cd.folder,'/','IBI.csv'));
            acc_name = cell2mat(strcat(cd.folder,'/','ACC.csv'));
            eda_name = cell2mat(strcat(cd.folder,'/','EDA.csv'));
            bvp_name = cell2mat(strcat(cd.folder,'/','BVP.csv'));
            temp_name = cell2mat(strcat(cd.folder,'/','TEMP.csv'));
            hr_name = cell2mat(strcat(cd.folder,'/','HR.csv'));
            IBI = csvread(hrt_name,1,0);
            ACC = readtable(acc_name);
            EDA = readtable(eda_name);
            %clear zero RR
            interval=120;
            ACC = table2array(ACC);
            acc_l = length(ACC);
            acc_ts = repmat(1/32,[acc_l-1 1]);
            acc_ts = [0 ; acc_ts];
            acc_ts = cumsum(acc_ts);
            ACC = [acc_ts ACC];
            total_time = IBI(end,1);
            mean_acc_mag = [];
            mean_acc_x = [];
            mean_acc_y = [];
            mean_acc_z = [];
            energy = [];
            for count =1:0.5:total_time/interval
               y = ACC(find(ACC(:,1)>interval*(count-1) & ACC(:,1)<interval*count),:);
               z = sqrt(y(:,2).^2 +y(:,3).^2 + y(:,4).^2);
               energy = vertcat(energy,sum(abs(fft(z)))/length(z));
               mean_acc_mag = vertcat(mean_acc_mag,mean(z));
               mean_acc_x = vertcat(mean_acc_x,mean(y(:,2)));
               mean_acc_y = vertcat(mean_acc_y,mean(y(:,3)));
               mean_acc_z = vertcat(mean_acc_z,mean(y(:,4)));
            end
            [fft_pLF,fft_pHF,fft_LFHFratio,fft_VLF,fft_LF,fft_HF,lomb_lf,RMSSD,PNN50,TRI,TINN,lomb_hf,meanV,stdV,sdsd,qr,peakpersecond] = FilterInterpolateWithSeconds(IBI,0.2,6,10);
            my_l = length(fft_pLF);
            session_id = c;
            %All features and session information table
            my_id=table2array(e4_vs_id(device_id,:));
            my_feature = horzcat(fft_pLF,fft_pHF,fft_LFHFratio,fft_VLF,fft_LF,fft_HF,lomb_lf,lomb_hf,RMSSD,PNN50,TRI,TINN,lomb_lf./lomb_hf,meanV,stdV,sdsd,mean_acc_mag,mean_acc_x,mean_acc_y,mean_acc_z,energy,qr,ones(my_l,1)*4,ones(my_l,1)*my_id,ones(my_l,1)*session_id);
            feature_vector = vertcat(feature_vector,my_feature);
            end
            
            
        end
        
        
end
%sessions are between 1 and 17
subj_vs_sessions = zeros(28,17);
fv=feature_vector;
s_fv = [];
for i = 1:17
    %get desired session
    sl = fv(:,25)==i;
    fvs = fv(sl,:);
    dvcs = unique(fvs(:,24),"rows");
    if(isempty(dvcs))
        continue
    end
    disp("session number "+ i+" number of S2 devices is " +length(dvcs)+ " and session is "+ session_infos.NOTE(i) );
    tlxs = readtable(strcat('Information_tables/',cell2mat(session_infos.Session(i)),'.csv'));
    tlxs_a = table2array(tlxs);
    disp("total device "+ length(tlxs_a(~isnan(tlxs_a(:,2)),2)))
    %pass to next iteration if no device is found

    for(m = 1:length(dvcs))
        c_d = dvcs(m);
        sub_sl = strcmp(subject_device.device_id, device_name_finder(4,c_d));
        subj_id = subject_device.Subject_id(sub_sl);
        subj_vs_sessions(subj_id,i) = 1;
        disp(subj_id)
        %get the current device
        %s2 => 2
        d_sl = fvs(:,24) == c_d & fvs(:,23) ==4;
        fvss = fvs(d_sl,:);
        %get acc and 
        acc = fvss(:,17:21);
        mean_acc = mean(acc,1);
        %get hrt
        hrt = fvss(:,1:16);
        %eleminate the points where more than %10 interpolated
        hrt = hrt(fvss(:,22)>=0.9,:);
        mean_hrt = mean(hrt,1);
        if(isempty(hrt))
            subj_vs_sessions(subj_id,i) = 1;
        else
        tmp = [mean_hrt mean_acc fvss(1,23:25)];
            if(sum([2 5 8 10 13 15 16 17] == i)>0)
            tmp = [tmp 2];
            elseif(sum([6 11] == i)>0)
                tmp = [tmp 1];
                else
                tmp = [tmp 3];
                end
        s_fv = vertcat(s_fv,tmp);
        end
    end
end
dlmwrite('Inzva_sessions_3_e4_class.txt',s_fv(:,[1:21 25] ))


subplot(3,1,1)
plot((table2array(IBI(:,1))-table2array(IBI(1,1)))/(60*1000),table2array(IBI(:,2)))
axis([0 120 30 150])
title('Mean HRT')
subplot(3,1,2)
plot((table2array(ACC(:,1))-table2array(ACC(1,1)))/(60*1000),sqrt(table2array(ACC(:,3)).^2 +table2array(ACC(:,4)).^2+table2array(ACC(:,5)).^2))
title('Acc magnitude')
axis([0 120 0 50])
subplot(3,1,3)
plot((table2array(LGT(:,1))-table2array(LGT(1,1)))/(60*1000),table2array(LGT(:,2)))
axis([0 120 0 15000])
title('Light magnitude')