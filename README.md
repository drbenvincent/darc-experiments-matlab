# The DARC Toolbox: automated, flexible, and efficient delayed and risky choice experiments using Bayesian adaptive design


### 🔥 The toolbox works robustly and has been used in a number of experiments so far. We are making this public now in order to get feedback on both the paper and software toolbox. Therefore, expect some changes and refinements in the software as things get polished.


This toolbox accompanies the paper:

> Vincent, B. T., & Rainforth, T. (2017, October 20). The DARC Toolbox: automated, flexible, and efficient delayed and risky choice experiments using Bayesian adaptive design. Retrieved from [psyarxiv.com/yehjb](https://psyarxiv.com/yehjb)

## Authors

- [Benjamin T. Vincent](http://www.inferencelab.com) ([@inferencelab](https://twitter.com/inferencelab)), University of Dundee.
- [Thomas Rainforth](https://github.com/twgr) ([@tom_rainforth](https://twitter.com/tom_rainforth)), University of Oxford.

We welcome feedback, bug reports and feature requests via email (to Ben Vincent), or via GitHub Issues, GitHub pull requests.

# What does this toolbox do?

This toolbox allows researchers to run Delayed and Risky Choice experiments using efficient adaptive methods (Bayesian Adaptive Design).

## Features
- **Set up experiments with minimal coding.** Set up and run adaptive experiments in just a few lines of code. See the examples and how-to's below.
- **Easily customise your prior beliefs over parameters.** This is a key feature of running efficient adaptive experiments.
- **Easy to customise the framing of choices presented to participants.** You can customise the commodity being offered (eg. dollars, British pounds, chocolate bars). You can also customise the framing of delays (presented as delays vs future date) or probabilties (probabilties vs odds).
- **Easy to customise the set of allowable rewards, delays and probabilities.** (i.e. the design space).
- **Interleave multiple adaptive experiments.** If you want to do interesting mixed-block experiments or react to the current estimates of model parameters (e.g. discount rates) then you can do that. You can do this by asking the experiment to run just one trial.
- **Inject custom trials.** Left to it's own devices, an experiment will choose it's own set of designs. But if you have particular experimental needs, you can inject your own (manually specified) designs amongst automatically run trials.
- **Point estimates of parameters are saved.**
- **Raw response data files are saved.** This allows more advanced scoring of response data (e.g. by multiple alternative decision making models). Reaction times are also saved.

# Requirements
To use this toolbox, you will need:
- Matlab 2016a or later
- Matlab's [Statistics and Machine Learning Toolbox](https://uk.mathworks.com/products/statistics.html)

# Documentation and help.

For the moment, documentation is primarily in the form of:
- code comments
- `README.md` docs, mainly this page that you are reading now.

# Questions, comments, feature requests bug reports
Feedback is very welcome. This can be done through:
- A GitHub Issue, or
- posting in our [darc-toolbox-matlab Google Group](https://groups.google.com/forum/#!forum/darc-toolbox-matlab)

# Installation and quick start

1. Get a local copy of the repository. If you are not so familiar with GitHub, then the easiest method is to download a `.zip`. Look for the big green button called "Clone or download".
2. Add the location of the `darc-experiments-matlab` folder you just downloaded to the Matlab path using the `addpath` command. Probably the easiest way to do this (especially if working across mac's and PC's) is to put the repository in the [`userpath`](https://uk.mathworks.com/help/matlab/ref/userpath.html), as you can then just use `addpath(fullfile(userpath, 'darc-experiments-matlab')` which should work on both mac's and PC's.
3. You must set up the Matlab environment by running the `env_setup()` function. But this only needs to be done once each time to start Matlab.
4. Run the code below to run a simple delay discounting experiment, using hyperbolic discounting as the model whose parameters are being estimated.

```matlab
% build a model object: include fixed parameter values
myModel = Model_hyperbolic1_time('epsilon', 0.01);

% build an experiment object. A GUI dialogue box will appear.
expt = Experiment(myModel);

% begin the adaptive experiment
expt = expt.runTrials();
```

If you get errors, ensure you have done steps 2 and 3. It is easy to forget to run `env_setup()` for step 3.


# Experiments available in the DARC toolbox

Below we give examples of the core experimental paradigms that are currently available, illustrated with real (not simulated) participants.

We are interested to hear from you about what experiments you would like to see feature in the DARC toolbox - please do get in touch.

## 1. Time discounting

We have already seen an example of time discounting above which uses the Hyperbolic discount function

```matlab
myModel = Model_hyperbolic1_time('epsilon', 0.01);
expt = Experiment(myModel);
expt = expt.runTrials();
```

But we can also run time discounting experiments, but assuming participants discount according to different discount functions. We can do this by creating different models, so in the above code we can replace `Model_hyperbolic1_time` with one of the other available models. The total list of current discount functions supported (currently) is:
- Hyperbolic discounting, `Model_hyperbolic1_time`
- Exponential discounting, `Model_exponential_time`
- **<< details to follow >>**

### Running the Kirby (2009) procedure
You can also run the Kirby (2009) procedure using our toolbox. This is not a pointless activity because it gives you real time posteriors over model parameters. You can run an experiment using the following code. Setting the `'plotting'` option as `'full'` gives you this real time plotting of posterior inferences.

```matlab
myModel = Model_hyperbolic1_time('epsilon', 0.01);
myModel.design_override_function = makeKirbyGenerator();
expt = Experiment(myModel, 'plotting', 'full');
expt = expt.runTrials();
```

### Running the Frye et al (2016) procedure
Similar to above, you can implement the Frye et al (2016) procedure using the code below. There are a few more options to specify.

```matlab
myModel = Model_hyperbolic1_time('epsilon', 0.01);
D_B = [7 30 90 180 365];
R_B = 100;
trials_per_delay = 10;
model.design_override_function = makeFryEtAlGenerator(D_B, R_B, trials_per_delay);
total_trials = numel(D_B) * trials_per_delay
% set number of trials in the GUI popup equal to total_trials
expt = Experiment(myModel, 'plotting', 'full');
expt = expt.runTrials();
```


## 2. Time discounting with magnitude effect

```matlab
myModel = Model_hyperbolic1ME_time('epsilon', 0.01);
expt = Experiment(myModel);
expt = expt.runTrials();
```

For the sake of completeness, we can also run this magnitude effect model, but with a fixed slope `m`, so that the model becomes equal to the hyperbolic model (where `c=log(k)` when `m=0`). * NOTE: We don't recommend this because the priors for `m` and `c` are set up assuming that there is a magnitude effect. *

```matlab
myModel = Model_hyperbolic1ME_time('m', 0, 'epsilon', 0.01);
expt = Experiment(myModel);
expt = expt.runTrials();
```


## 3. Probability discounting

Note that if you are running probability discounting experiments and present probabilities in terms of odds (see below) then you might want to customise the design space so that whole-numbered odds are presented to participants. Full details in the "How-to" sections below.

### Hyperbolic discounting of odds against a risky prospect
Experiments assuming hyperbolic discounting of log odds against the risky prospect can be run with:

```matlab
myModel = Model_hyperbolic1_prob('epsilon', 0.01);
expt = Experiment(myModel);
expt = expt.runTrials();
```

### Hyperboloid discounting of odds against a risky prospect
And we can run a similar experiment assuming hyperboloid discounting of log odds against the risky prospect with:

```matlab
myModel = Model_hyperboloid_prob('epsilon', 0.01);
expt = Experiment(myModel);
expt = expt.runTrials();
```

where we use the function: `v = 1/[(1+h*odds)^s]`, which has 2 parameters `h` and `s`, see Green & Myerson(2004).

## 4. Time and probability discounting

```matlab
myModel = Model_hyperbolic1_time_and_prob('epsilon', 0.01);
expt = Experiment(myModel);
expt = expt.runTrials();
```

# How to

## How to specify custom priors over parameters
All of the models are built with prior distributions by default. But you can very easily update the priors over parameters. After you create a `Model` object like normal, you can call the `setPrior` method and provide the parameter name and the updated prior (in the form of a Matlab probability object).

For example, if you were testing participants who you expect to have a high present bias (higher `logk` value) then you can represent this prior belief like so:

```matlab
% build a model like normal
myModel = Model_hyperbolic1_time('epsilon', 0.01);
% now update prior with the setPrior method call
custom_logk_prior = makedist('Normal', 'mu',-3, 'sigma',sqrt(4));
myModel = myModel.setPrior('logk', custom_logk_prior);
% build an experiment object. A GUI dialogue box will appear.
expt = Experiment(myModel);
expt = expt.runTrials();
```

If you want to update more than one parameter, simply make another call to `myModel.setPrior` with the relevant parameter name and probability distribution object.

You should be able to provide any *univariate* Matlab probability distribution object which you can make with the [`makedist`](https://uk.mathworks.com/help/stats/makedist.html) function.

## How to customise the design space

You can override the default design space by using key/value arguments into the `Model` construction. For example, if we want to customise the set of possible delayed rewards `D_B` and delayed reward values `R_B`:

```matlab
D_B = [1/24 .* [1 2 3 4 5 6]...   % hours
    1 2 3 4 5 6 ...               % days
    7 * [1 2 3] ...               % weeks
    30 * [1 2 3 4 5 6]...         % months
    365 * [1 2 5]];               % years

myModel = Model_hyperbolic1_time('epsilon', 0.01,...
    'R_B', [90 100 110],...
    'D_B', D_B);
```

### Customising risky choice experiments, with odds framing
When you run a risky choice experiment and want to present in odds (rather than probabilities), you might want to do something like the following in order to test whole-numbered odds.

```matlab
% create P_B values
oddsvec = [20 15 10 5 4 3 2];
P_B_oddsframe = oddsagainst2prob([oddsvec 1 fliplr(1./oddsvec)]);

% feed them in to the model
myModel = Model_hyperbolic1_prob('epsilon', 0.01,...
    'P_B', P_B_oddsframe);
myExpt = Experiment(myModel);
myExpt = myExpt.set_human_response_options(...
	{'commodity_type', 'GBP',...
	'prob_framing', 'odds'});
```


## How to customise question framing
Currently, when an experiment is run with a non-simulated agent, we call the function `getHumanResponse.m`. This has various defaults which leads to a sensible way to present prospects to participants in the form of text which is presented in buttons.

The details of this question presentation can be altered by calling the `set_human_response_options` method on the `Experiment` object, like in the example below:

```matlab
myModel = Model_hyperbolic1_time('epsilon', 0.01);
expt = Experiment(myModel);
expt = expt.set_human_response_options({'commodity_type', 'GBP',...
    'delay_framing', 'date'});
expt = expt.runTrials();
```

The input must be a cell array of strings which are key/value pairs. The options currently are:

| option  | values |
| ------------- | ------------- |
| `'commodity_type'`  | `'USD'` [default], `'GBP'`, `'song_downloads'`, `'sex'`, `'chocolate bars'`  |
| `'delay_framing'`  | `'delay'` [default], `'date'`  |
| `'prob_framing'`  | `'prob'` [default], `'odds'`  |


When `delay_framing` is set to `delay`, then future rewards will be presented in terms of a delay from now (ie. days, weeks, months, years from now).

When `delay_framing` is set to `date`, then future rewards will be presented as occurring on a particular date.

### Need even more options?
The easiest way to add more framing options is to either go and edit the `getHumanResponse.m` file, or to create a feature request.

## How to customise name of saved files?
If you are running multiple experiments, then you will need to be able to look at the saved outputs and clearly be able to link these to the particular experiment. These different experiments may involve different models, experimental conditions, question framing types, etc.

You can specify some text which will be included in the filenames. These will also include some core information such as: participant ID, date and time at the start of the experiment, and the model type used. The example below shows how to provide this (optional) text to the filenames of saved files.

```matlab
myModel = Model_hyperbolic1_time('epsilon', 0.01);
expt = Experiment(myModel);
% customise save text in the line below
expt = expt.set_save_text('timediscounting-delayframe-gain');
```

This will result in filenames which have this basic form:

    DOE_J-2017Nov07-10.07-timediscounting-delayframe-gain-Model_hyperbolic1_time-rawdata.csv

where the last token shows this is for the raw trial data. Or

    DOE_J-2017Nov07-10.07-timediscounting-delayframe-gain-Model_hyperbolic1_time-params.csv

for the exported point estimates of parameters.

It will aid you in the long run if you give a bit of thought into the form of the `save_text` you provide. Having unless you are going to process these files manually, it will be much easier to write a function to parse these filenames in your analysis code if you keep the ordering and naming of items in `save_text` coherent.

## How to use advanced or atypical choice elicitation methods
The current implementation elicits questions in the form of text in buttons that a human user can click on. If you want to drive more complex response elicitation methods, like interesting GUI displays, or some crazy custom set up for electrophysiology, then we are happy to work with you. We'd probably implement this by using callback functions, but please do get in touch.

The adventurous could try replacing `getHumanResponse.m` with their own function - as long as you keep the inputs to, and outputs from, that function the same then it should be doable.


## How to interleave multiple experiments

As well as calling the `runTrials` method on the experiment (which will run the whole experiment), you can also run an experiment trial-wise. This gives the experimenter more flexibility in running multiple experiments in an interleaved manner, for example. This is demonstrated below:

```matlab
% set up time discounting model and experiment
time_model = Model_hyperbolic1_time('epsilon', 0.01);
time_expt = Experiment(time_model);

% set up probability discounting model and experiment
prob_model = Model_hyperbolic1_prob('epsilon', 0.01);
prob_expt = Experiment(prob_model);

% Can now call runOneTrial() method of each experiment object as you like
for trial = 1:30
    if rand < 0.5
        time_expt = time_expt.runOneTrial();
    else
        prob_expt = prob_expt.runOneTrial();
    end
end
```

## How to simultaneously fit multiple models
The example above illustrates if we want to run a time discounting experiment, interleaved with a probability discounting experiment. But what if we want to just focus on time discounting, and do simultaneous parameter estimation for the hyperbolic time discounting model and the exponential time discounting model?

This is entirely doable and demonstrated in the example below. This example selects designs alternately from the exponential model and the hyperbolic models. But after each trial, we provide the design and response data to the other model, such that the posterior parameter estimates for both models is based upon _all_ the data collected.

```matlab
% create desired models and experiments
exponentialModel = Model_exponential_time('epsilon', 0.01);
hyperbolicModel = Model_hyperbolic1_time('epsilon', 0.01);

exponentialExpt = Experiment(exponentialModel, 'plotting', 'full'); % a GUI dialogue box will appear
hyperbolicExpt = Experiment(hyperbolicModel, 'plotting', 'full'); % a GUI dialogue box will appear

% begin the adaptive experiments
for trial = 1:30
    if mod(trial,2) % run trial with exponential model on even trials
        exponentialExpt = exponentialExpt.runOneTrial();
        % update posteriors of other model(s) with this trial data
        [last_design, last_response] = exponentialExpt.get_last_trial_info();
        hyperbolicExpt = hyperbolicExpt.enterAgentResponse(last_design, last_response);
    else % run trial with hyperbolic model on odd trials
        hyperbolicExpt = hyperbolicExpt.runOneTrial();
        % update posteriors of other model(s) with this trial data
        [last_design, last_response] = hyperbolicExpt.get_last_trial_info();
        exponentialExpt = exponentialExpt.enterAgentResponse(last_design, last_response);
    end
end
```

Note 1: This is _not_ optimally selecting designs to differentiate between models. Readers interested in this are referred to Cavagnaro et al (2016). Our approach as outlined in Vincent & Rainforth (in prep) can be extended to simultaneous parameter estimation, achieving a similar goal as in Cavagnaro et al (2016), but at this point we have not implemented it.

Note 2: This is not the most elegant implementation. We may provide a smoother way to do this if it is something that people are keen on doing frequently.


## How to override the GUI asking for experiment options
By default each time an `Experiment` object is constructed, we get a GUI which asks for the participant ID and number of trials for that experiments. This is fine when running one experiment, but if we are running multiple experiments on a single participant, we may not want to input this information in repeatedly.

Instead, we could for example just get the experiment options once at the start, using

```matlab
expt_options = getHumanExperimentOptions();
```

which produces a structure

    expt_options =
      struct with fields:

               trials: 10.00
        participantID: 'DOE_JON-2017Nov08-13.17'

We can then just provide these experiment options manually when we create however many experiments we like. For example,

```matlab
hyperbolic_time_discounting_model = Model_hyperbolic1_time('epsilon', 0.01);
% first experiment with default delay framing
expt(1) = Experiment(hyperbolic_time_discounting_model,...
	'expt_options', expt_options);
% second experiment with date framing
expt(2) = Experiment(hyperbolic_time_discounting_model,...
	'expt_options', expt_options);
expt(2) = expt(2).set_human_response_options({'delay_framing', 'date'});
```


## How to inject manually-specified trials
It is possible to interleave both automatic and manually-specified trials. Below is an example of how to do this with the `runOneManualTrial` method.

*Experimental scenario:* Let's say you want to run an experiment where you are interested in reaction times to choices made as a function of how difficult those choices are (i.e. how far they are from the indifference point). You could do this by running an entirely automated experiment to determine the indifference point and then run some custom trials that have a pre-specified distance from the indifference point. Alternatively, you could interleave automatically determined trials with custom trials where you are simultaneously estimating model parameters and injecting your own trials based on the current model parameters.

```matlab
myModel = Model_hyperbolic1_time('epsilon', 0.01);
myExpt = Experiment(myModel);

% Every 5th trial, run a manually-specified trial
for trial = 1:40
    if rem(trial,5)==0
        % Automatic trial
        myExpt = myExpt.runOneTrial();
    else
        % ---- construct your manual experimental design here ----
        % >> manual_design = <your code here>
        myExpt = myExpt.runOneManualTrial(manual_design);
    end
end
```




## How to run simulated experiments
You can also run simulated participants through the adaptive experiments. This is useful in order to test things when customising your design space, when building new tools (experiment paradigms), or to run parameter recovery simulations.

```matlab
myModel = Model_hyperbolic1_time('epsilon', 0.01);
% build an experiment object. But provide extra arguments
expt = Experiment(myModel,...
    'agent', 'simulated_agent',...
    'true_theta', struct('logk', -3, 'alpha', 2));
expt = expt.runTrials();
```

Just to highlight the differences, compared to running real participants you must do the following things in order to run simulated experiments:
1. Tell the `Experiment` object that the `'agent'` value is equal to `'simulated_agent'` (rather than it's default value of `'real_agent'`).
2. You need to provide true parameter values of the simulated agent to the `Experiment` object.

Note that only `epsilon` is defined as a fixed parameter when constructing the model. This is because we still want to conduct inference over the `logk` and `alpha` parameters. But, in the `Experiment` we provide our additional 'secret experimenter' knowledge that the simulated agent has specific `logk` and `alpha` values.

You can also override the default number of simulated trials with the following optional input argument into `Experiment`:

```matlab
expt = Experiment(myModel,...
    'agent', 'simulated_agent',...
    'true_theta', struct('logk', -3, 'alpha', 2),...
    'trials', 10);
```

## How to reproduce the figures in our paper
You should be able to do this straightforwardly by running the `make_plots_for_paper()` function. Note that this could take some time as it invokes a lot of simulated experiments and parameter recovery simulations.


# Outputs of running an experiment
Thus far the following outputs are generated:

## Raw response data
A comma separated `.csv` file is saved with the raw response data. Each row is a trial. This is saved after every trial in order to ensure data is saved in the advent of an error, power failure, or other melt-down.

## Point estimates of parameters
A comma separated `.csv` file is exported containing the point estimates of the parameters. Each column is a parameter.

## Figures
By default, a set of figures are produced at the end of the experiment. This can be overridden by passing in the optional key/value pair when constructing the `Experiment` object.

The input `plotting` can be set to:
- `end` [default] plots figures at the end of the experiment.
- `none` for no plotting at all.
- `full` will update plots with every trial of the experiment. This is useful for inspection and understanding, rather than use in real experiments.


# What can you do after an experiment is finished?
As well as the automatically saved outputs (described above) you can do a few things with the `Experiment` class. Let's say you have run an experiment, using code such as:

```matlab
myModel = Model_hyperbolic1_time('epsilon', 0.01);
expt = Experiment(myModel);
expt = expt.runTrials();
```

You can then do various things with this fitted `Experiment` class.

## Get the joint posterior distribution over parameters
  This will return the full set of particles which represent the joint distribution.


    >> posterior_particles = expt.get_theta_as_struct()
    posterior_particles =
    struct with fields:
        logk: [50000×1 double]
        alpha: [50000×1 double]
        epsilon: [50000×1 double]


You can then do whatever analysis you want on these, such as compute summary statistics:

    >> median(posterior_particles.logk)
    ans =
       -4.4904

## Access the raw data table
As well as being exported to disc, you can programmatically access the raw data table like this:

    >> expt.data_table
    ans =
      4×8 table
        D_A    P_A    R_B    D_B    P_B    R_A    R    reaction_time
        ___    ___    ___    ___    ___    ___    _    _____________
        0      1      100    90     1      50     A    2.9743       
        0      1      100    28     1      60     A    2.1513       
        0      1      100    21     1      55     B    1.7055       
        0      1      100    28     1      55     A    1.8099  


# Analysing data
This toolbox is designed for data collection. The toolbox does export estimated parameter estimates, and you can use these as data points in your larger experimental data file of multiple participants and conditions etc. However, the default priors over parameters used by the toolbox were chosen to be both general, but also give rise to stable and sensible estimates based upon an individual agent's data.

Another good way to proceed, is to use the [Hierarchical Bayesian Discounting toolbox](https://github.com/drbenvincent/delay-discounting-analysis) by Vincent (2016) which (currently) focusses on analysing data from delay discounting procedures.


# Acknowledgements
The **darc-experiments-matlab** toolbox uses code from:
- [export-fig](https://github.com/altmany/export_fig)


# References
Cavagnaro, D. R., Aranovich, G. J., McClure, S. M., Pitt, M. A., & Myung, J. I. (2016). On the functional form of temporal discounting: An optimized adaptive test. Journal of Risk and Uncertainty, 1–22.

Frye, C. C. J., Galizio, A., Friedel, J. E., DeHart, W. B., and Odum, A. L. (2016). Measuring Delay Discounting in Humans Using an Adjusting Amount Task. Journal of Visualized Experiments, (107):1–8.

Green, L., & Myerson, J. (2004). A Discounting Framework for Choice With Delayed and Probabilistic Rewards., 130(5), 769–792.

Kirby, K. N. (2009). One-year temporal stability of delay-discount rates. Psychonomic Bulletin & Review, 16(3):457–462.

Vincent, B. T. (2016) [Hierarchical Bayesian estimation and hypothesis testing for delay discounting tasks](https://link.springer.com/article/10.3758/s13428-015-0672-2), Behavior Research Methods. 48(4), 1608-1620.

Vincent, B. T., & Rainforth, T. (2017, October 20). The DARC Toolbox: automated, flexible, and efficient delayed and risky choice experiments using Bayesian adaptive design. Retrieved from [psyarxiv.com/yehjb](https://psyarxiv.com/yehjb)
