function examples = makeExamples()
% Creates a data structure containing log(k) parameters for 3 examples

n=1;
examples(n).title = 'major depressive disorder';
examples(n).halfLifeDays = 1/0.04;
examples(n).true_theta = log(1/examples(n).halfLifeDays);

n=2;
examples(n).title = 'upper income older adults';
examples(n).halfLifeDays = 1/0.01;
examples(n).true_theta = log(1/examples(n).halfLifeDays);

n=3;
examples(n).title = 'anorexia nervosa';
examples(n).halfLifeDays = 1/0.0028;
examples(n).true_theta = log(1/examples(n).halfLifeDays);

return
