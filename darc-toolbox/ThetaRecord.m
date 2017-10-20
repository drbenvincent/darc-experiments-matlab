classdef ThetaRecord
    %ThetaRecord Stores a record of a probability distribution (represented
    %by a set of samples/particles) over time as the posterior updates in
    %the ligt of new data. This class represents ONE univariate variable.
    
    properties % TODO: make these private or protected and add appropriate get/set as neeed
        true_value
        name
    end
    
    properties (Access = protected)
        mean
        median
        sigma
        var
        HDI
        grid, high_res_grid, entropy_bits, kde, kde_high_res
        time_vec
    end
    
    methods
        
        function obj = ThetaRecord(name, varargin)
            
            p = inputParser;
            p.FunctionName = mfilename;
            p.addRequired('name',@isstr);
            p.addParameter('samples', [], @isvector);
            p.addParameter('grid', [], @isvector);
            p.addParameter('true_value', [], @isscalar);
            p.parse(name, varargin{:});
            
            % add arguments to object
            obj.name = p.Results.name;
            obj.grid = p.Results.grid;
            if ~isempty(p.Results.grid)
                obj.high_res_grid = linspace(min(obj.grid), max(obj.grid), 1000);
            end
            obj.true_value = p.Results.true_value;
            if ~isempty(p.Results.samples)
                obj = obj.addSamples(p.Results.samples);
            end
        end
        
        function obj = addSamples(obj, samples)
            %ADDSAMPLES
            % Call this function on each iteration, providing a new set of
            % samples. The function will compute and store various summary
            % statistics.
            
            % Calculate point estimates and append to lists
            obj.mean = [obj.mean mean(samples)];
            obj.median = [obj.median median(samples)];
            obj.sigma = [obj.sigma std(samples)];
            obj.var = [obj.var var(samples)];
            % Calculate entropy
            obj.entropy_bits = [obj.entropy_bits obj.entropy_of_distribution(samples)];
            % Calculate 95% HDI
            obj.HDI = [obj.HDI ; obj.HDIofSamples(samples, 0.95)];
            % Store kde
            obj = obj.store_kde(samples);
            % Keep log of time
            if isempty(obj.time_vec)
                obj.time_vec = 0;
            else
                obj.time_vec = [obj.time_vec obj.time_vec(end)+1];
            end
        end
        
        function plot_summary(obj)
            % plots median +/- sigma for the parameter. If we have an
            % object array, then we plot these as multiple rows, calling
            % the plot function on each item.
            
            % LOOP OVER OBJECT ARRAY
            for n=1:numel(obj)
                subplot(numel(obj), 1, n)
                hold off
                my_plot(obj(n))
            end
            
            function my_plot(obj_element)
                errorbar(obj_element.time_vec, obj_element.median, obj_element.sigma)
                ylabel(obj_element.name)
                if ~isempty(obj_element.true_value)
                    hold on
                    plot([0 max(obj_element.time_vec)],...
                        [obj_element.true_value obj_element.true_value],...
                        'r--')
                end
                set(gca,'box', 'off',...
                    'XTick', obj_element.time_vec,...
                    'XLim', [-0.1 max(obj_element.time_vec)])
            end
        end
        
        function plot_median(obj, lineOptions)
            % plots medians for the parameter. If we have an
            % object array, then we plot all on the same axis
            
            % LOOP OVER OBJECT ARRAY
            for n=1:numel(obj)
                hold on
                h(n) = my_plot(obj(n));
            end
            set(h, lineOptions{:});
            
            function h = my_plot(obj_element)
                h = plot(obj_element.time_vec, obj_element.median);
                ylabel('posterior median')
            end
        end
        
        
        function plot_entropy_lines(obj, lineOptions)
            % LOOP OVER OBJECT ARRAY
            for n=1:numel(obj)
                hold on
                h(n) = my_plot(obj(n));
            end
            set(h, lineOptions{:});
            
            ylabel([obj(1).name ' posterior entropy (bits)'], 'Interpreter','latex')
            xlabel('trial', 'Interpreter','latex')
            set(gca,'box', 'off',...
                'XTick', obj(1).time_vec,...
                'XLim', [-0.1 max(obj(1).time_vec)])
            
            function h = my_plot(obj_element)
                if isempty(obj_element.entropy_bits)
                    return
                end
                h = plot(obj_element.time_vec, obj_element.entropy_bits);
            end
        end
        
        
        function [h_line] = plot_entropy_shaded(obj, patchOptions, lineOptions)
            % build x,y data by looping over object array and extracting values
            for n = 1:numel(obj)
                if isempty(obj(n).entropy_bits), continue, end
                x(n,:) = obj(n).time_vec;
                y(n,:) = obj(n).entropy_bits;
            end
            
            % plot CI region
            [h_patch, h_line] = ribbon_plot(x(1,:), y, [50]);
            set(h_patch, patchOptions{:});
            set(h_line, lineOptions{:});
            
            % 			% plot mean
            % 			h_mean = plot( x(1,:), mean(y,1) );
            % 			set(h_mean, patchOptions{:});
            
            % Axis formatting
            ylabel([obj(1).name ' posterior entropy (bits)'], 'Interpreter','latex')
            xlabel('trial', 'Interpreter','latex')
            set(gca,'box', 'off',...
                'XTick', obj(1).time_vec,...
                'XLim', [-0.1 max(obj(1).time_vec)])
        end
        
        
        function plot_kde(obj, style)
            if isempty(obj.kde), return, end
            hold off
            switch style
                case{'all'}
                    imagesc(obj.time_vec, obj.grid, obj.kde')
                    set(gca,'box', 'off',...
                        'XTick', obj.time_vec)
                    ylabel([obj.name ' (kde)'])
                case{'prior'}
                    plot(obj.grid, obj.kde(1,:))
                    xlabel(obj.name)
                case{'current posterior'}
                    plot(obj.grid, obj.kde(end,:))
                    xlabel(obj.name)
            end
        end
        
        
        function plot_kde_vertical(obj, lineOptions)
            % LOOP OVER OBJECT ARRAY
            for n=1:numel(obj)
                hold on
                h(n) = my_plot(obj(n));
            end
            set(h, lineOptions{:});
            
            function h = my_plot(obj_element)
                if isempty(obj_element.entropy_bits)
                    return
                end
                h = plot(obj_element.kde_high_res(end,:), obj_element.high_res_grid );
            end
        end
        
        function plot_param_recovery(obj)
            
            % plot line of equality
            plot([min([obj.true_value]) max([obj.true_value])],...
                [min([obj.true_value]) max([obj.true_value])], 'k-')
            
            % LOOP OVER OBJECT ARRAY
            for n=1:numel(obj)
                hold on
                h(n) = my_plot(obj(n));
            end
            %set(h, lineOptions{:});
            xlabel('true value')
            ylabel('inferred value')
            
            box off
            axis equal
            axis square
            
            function h = my_plot(obj_element)
                x = [obj_element.true_value(end),...
                    obj_element.true_value(end)];
                % 				y = [obj_element.median(end) - obj_element.sigma(end),...
                % 					obj_element.median(end) + obj_element.sigma(end)];
                y = [obj_element.HDI(end,1), obj_element.HDI(end,2)];
                
                % error bar
                h = plot(x,y,'k-');
                % point
                h_point = plot(obj_element.true_value, obj_element.median(end),'k+');
                set(h_point,'MarkerFaceColor','w',...
                    'MarkerSize',3)
            end
        end
        
    end
    
    methods (Access = private)
        
        function E = entropy_of_distribution(obj, samples)
            if isempty(obj.grid)
                E = [];
                return
            end
            E = entropy_of_distribution(samples, obj.grid);
        end
        
        function obj = store_kde(obj, samples)
            if isempty(obj.grid), return, end
            obj.kde = [obj.kde ; obj.calc_kde(samples, obj.grid)];
            obj.kde_high_res = [obj.kde_high_res ; obj.calc_kde(samples, obj.high_res_grid)];
        end
        
    end
    
    methods (Access = private, Static)
        
        function kde = calc_kde(samples, grid)
            kde = ksdensity(samples, grid);
            kde = kde./sum(kde);
        end
        
        function [HDI] = HDIofSamples(samples, credibilityMass)
            %
            % [HDI] = HDIofSamples(samples, 0.95)
            %
            % Directly translated from code in:
            % Kruschke, J. K. (2015). Doing Bayesian Data Analysis: A Tutorial with R,
            % JAGS, and Stan. Academic Press.
            
            assert(credibilityMass > 0 && credibilityMass < 1,...
                'credibilityMass must be a between 0-1.')
            
            samples = sort(samples(:));
            ciIdxInc = floor( credibilityMass * numel( samples ) );
            nCIs = numel( samples ) - ciIdxInc;
            
            ciWidth=zeros(nCIs,1);
            for n =1:nCIs
                ciWidth(n) = samples( n + ciIdxInc ) - samples(n);
            end
            
            [~, minInd] = min(ciWidth);
            HDImin	= samples( minInd );
            HDImax	= samples( minInd + ciIdxInc);
            HDI		= [HDImin HDImax];
        end
    end
    
end
