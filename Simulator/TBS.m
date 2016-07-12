classdef TBS < handle % transfer block size
    properties
        N_RB
        TBs
        to4layer
        to3layer
        to2layer
        c1_format
        MCS_TBS_index_table
        
    end
    methods
        function obj = TBS (file)
%             try 
%                 load(file,'obj');
%             catch err
                [~,sheet_name]=xlsfinfo(file);
                obj.TBs=zeros(27,110,4);
                obj.TBs(:,:,1)      =xlsread(file,sheet_name{1});
                obj.to2layer =xlsread(file,sheet_name{2});
                obj.c1_format=xlsread(file,sheet_name{3})';
                obj.to3layer =xlsread(file,sheet_name{4});
                obj.to4layer =xlsread(file,sheet_name{5});
                obj.MCS_TBS_index_table=xlsread(file,sheet_name{6});
                obj.N_RB=1:110;
                obj.layers_TBS;
%             end
            
        end
        function [MCS_index,modulation_order,TBS_index,TBS_size,n_CW,efficiency]= get_MCS_index(obj,CQI,N_RB,n_layer,par, n_CW)
            CQI=floor(CQI);
            if CQI~=0
                efficiency=par.CQI_params(CQI).efficiency;
                TBS_max=max((efficiency * par.sym_per_RB_sync*2 * N_RB *n_layer) -par.CRC_length,0); % 2 time slot
                TBS_to_cmp=obj.TBs(:,N_RB,n_layer);
                TBS_size=max(TBS_to_cmp(TBS_to_cmp <= TBS_max));
            if isempty(TBS_size)
                TBS_size=TBS_to_cmp(1); %% I dont know should I put it to zero or not
            end

            
%             if tx_mode>1 && n_CW==2
%                 i_=floor(tx_mode/2);
%                 j_=ceil(tx_mode/2);
%                     
%                 TBS_size=[8*rand(1/8 * TBS_size *i_/tx_mode) 8*rand(1/8 * TBS_size*j_ /tx_mode)];
%                 n_CW=2;
%                 
% 
%             else
%                 n_CW=1;
%                 
%                 
%             end
            if n_CW ==1
                    TBS_index = find(TBS_to_cmp == TBS_size)-1;
                    ind = find(obj.MCS_TBS_index_table(:,3)==TBS_index);
                    if numel(ind) > 1
                        m_order =   obj.MCS_TBS_index_table(ind,2)   ;
                        i_= m_order== par.CQI_params(CQI).modulation_order;
                        ind=ind(i_);                       % get the biggest MCS index
                        ind=ind(end);
                    end
                    modulation_order    =  obj.MCS_TBS_index_table(ind,2) ;
                    MCS_index           = obj.MCS_TBS_index_table(ind,1);
                    efficiency = (TBS_size+ par.CRC_length)/(par.sym_per_RB_sync*2 * N_RB *n_layer); % bit per OFDM symbol
                
            else
                
                
            end
            else
                TBS_index=0;
                modulation_order=0;
                MCS_index=0;
                efficiency=0;
                TBS_size=0;
            end
            
            
                

            
        end
        function layers_TBS(obj)

            for i_=1:size(obj.to2layer,1)
                index=false(size(obj.TBs));
                index(:,:,2)=(obj.TBs(:,1:110,1)==obj.to2layer(i_,1));
                obj.TBs(index)=obj.to2layer(i_,1);
                
            end
            for i_=1:size(obj.to3layer,1)
                index=false(size(obj.TBs));
                index(:,:,3)=(obj.TBs(:,1:110,1)==obj.to3layer(i_,1));
                obj.TBs(index)=obj.to3layer(i_,1);
                
            end
            for i_=1:size(obj.to4layer,1)
                index=false(size(obj.TBs));
                index(:,:,4)=(obj.TBs(:,1:110,1)==obj.to4layer(i_,1));
                obj.TBs(index)=obj.to4layer(i_,1);
                
            end
            obj.TBs(:,1:55,2)=obj.TBs(:,2:2:110,1);
            obj.TBs(:,1:36,3)=obj.TBs(:,3:3:110,1);
            obj.TBs(:,1:27,4)=obj.TBs(:,4:4:110,1);
            
            
                           
        end

    end
end
    
    