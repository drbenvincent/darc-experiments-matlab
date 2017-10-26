function [response] = getHumanResponse(prospectA, prospectB, varargin)

%% Parse inputs
opts = inputParser;
opts.FunctionName = mfilename;
opts.addRequired('prospectA',@isstruct);
opts.addRequired('prospectB',@isstruct);
opts.addParameter('commodity_type', 'USD', @isstr);
opts.addParameter('delay_framing', 'delay', @isstr);
opts.addParameter('prob_framing', 'prob', @isstr);

opts.parse(prospectA, prospectB, varargin{:});


%% Do stuff here
question_posed = 'Which would you prefer?';
aText = constructQuestionString(prospectA, opts.Results);
bText = constructQuestionString(prospectB, opts.Results);
% Get the response via GUI
[didChooseB, reaction_time] = presentQuestionGUI(question_posed, aText, bText);

%% Package up output into a structure/object
response.didChooseB = didChooseB;
response.reaction_time = reaction_time;
end


function [optionString] = constructQuestionString(prospect, opts)

%% Compose reward string
switch opts.commodity_type
    case{'USD'}
        commodity.prefix = '$';
        commodity.suffix = '';
        
    case{'GBP'}
        commodity.prefix = '£';
        commodity.suffix = '';
        
    case{'song_downloads'}
        commodity.prefix = '';
        commodity.suffix = ' song downloads';
        
    case{'sex'}
        commodity.prefix = '';
        commodity.suffix = ' mins of sexual activity';
        
    case{'chocolate bars'}
        commodity.prefix = '';
        commodity.suffix = ' bars of chocolate';
        
    otherwise
        error('requested commodity_type not defined')
end

% compose reward (eg $100, or 15 dohnuts)
offerStr = [commodity.prefix sprintf('%.2f', prospect.reward) commodity.suffix];

%% Compose delay string
switch opts.delay_framing
    case{'delay'}
        % convert delays (in days) to clearer days or months or years
        delayStr = days2string(prospect.delay);
        
    case{'date'}
        if prospect.delay==0
            delayStr = 'now';
        else
            % calculate now + delay, in the form of a date
            date = datetime('now') + days(prospect.delay);
            % convert to string
            %delayStr = char(date);
            
            the_month = month(date,'name');
            delayStr = [num2str(date.Day) ' ' the_month{:} ' ' num2str(date.Year)];
        end
        
    otherwise
        error('requested delay_framing not defined')
end

%% Compose probability string

switch opts.prob_framing
    case{'prob'}
        if prospect.prob==1
            probStr = '';
        else
            probStr = [sprintf('%g', prospect.prob*100) '% chance of winning '];
        end
        
    case{'odds'}
        if prospect.prob==1
            probStr = '';
        elseif prospect.prob >= 0.5
            odds = prob2odds(prospect.prob);
            probStr = [num2str(odds) ':1 of winning '];
        else
            odds = prob2odds(1-prospect.prob);
            probStr = [num2str(odds) ':1 against winning '];
        end
    otherwise
        error('requested prob_framing not defined')
end

%% Glue together the commodity, delay and probability strings
if prospect.delay==0
    % reward is immediate
    optionString = [probStr offerStr ' now'];
else
    
    switch opts.delay_framing
        case{'delay'}
            % "[25% chance of winning] [$100] in [7 days]"
            optionString = [probStr offerStr ' in ' delayStr];
            
        case{'date'}
            % "[25% chance of winning] [$100] on [date]"
            optionString = [probStr offerStr ' on ' delayStr];
    end
    
end

end