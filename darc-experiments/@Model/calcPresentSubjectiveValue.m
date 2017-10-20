function presentSubjectiveValue = calcPresentSubjectiveValue(obj, prospect, params)
%presentSubjectiveValue = calcPresentSubjectiveValue({designs}, {parameters})
%
% Calculates the present subjective value for a prospect (reward, delay, prob), given the parameters provided

presentSubjectiveValue = ...
    obj.utilityFunction(prospect, params) .* ...
    obj.probWeightingFunction(prospect, params) .* ...
    obj.delayDiscountingFunction(prospect, params);
end
