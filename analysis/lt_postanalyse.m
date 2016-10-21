
load ('AllData/fnames.odat', 'fnames');

async = 0;
sync = 0;
nodistract = 0;
unknown = 0;

index = 1;
for name = fnames

    corr_meansd = fnames{2,index};
    incorr_meansd = fnames{3,index};
    r_latency = fnames{4,index};
    r_latency_correct = fnames{5,index};
    r_latency_incorrect = fnames{6,index};
    r_latency_toofast = fnames{7,index};
    params = fnames{8,index};

    if (params.tAttesoDisturbo == 0.4 && params.disturbYN == 1)
        async = async + 1;
    elseif (params.tAttesoDisturbo < 0.00001 && params.disturbYN == 1)
        sync = sync + 1;
    elseif (params.tAttesoDisturbo < 0.00001 && params.disturbYN == 0)
        nodistract = nodistract + 1;
    elseif (params.tAttesoDisturbo >=0.00001 && params.disturbYN == 0)
        nodistract = nodistract + 1;
    else 
        unknown = unknown + 1;
    end
    
    % Mean jump time for the target must be 0.8 seconds
    if (params.tAtteso ~= 0.8)
        disp([fnames{1,index} ' has wrong tAtteso!!']);
    end
    
    % Ok, can now do stuff!
        
    % Add r_latency, etc etc to some tables to store them for
    % posterity.
    index = index + 1;
end

%display ('-------');
async
sync
nodistract
unknown