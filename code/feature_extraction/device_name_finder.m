function d_n_f = device_name_finder(model_c,device_c)
        model = '';
        id = '';
        if(model_c == 1)
           model = 'S1';
        elseif(model_c ==2)    
           model = 'S2';
        elseif(model_c ==3)
           model = 'S3';
        elseif(model_c ==4)
           model = 'E4';
        end
        d_n_f = strcat(model,'_',mat2str(device_c));
                
end