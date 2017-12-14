function GeneratePIOutput(allFilesNames, experiment, outputName, numberOfFlies, expName)
choice = questdlg('Which side is the ligth in the experiment?', 'Choose Side', 'Left', 'Right', 'Don''t Know', 'Don''t Know');
switch choice
    case 'Left'
        lightIsOnLeft = true;
    case 'Right'
        lightIsOnLeft = fulse;
    case 'Don''t Know'
        warndlg('Default side for light (left) is used.');
        lightIsOnLeft = true;
    case ''
        warndlg('Default side for light (left) is used.');
        lightIsOnLeft = true;
end
runningExperiment(allFilesNames, outputName, lightIsOnLeft, experiment, numberOfFlies, expName);
end

function runningExperiment(allFilesNames, outputName, lightIsOnLeft, experiment, numberOfFlies, expName)
%Running the system
%   the main function handles all the inputs from the Ctrax after error
%   fixing and adapt the data to be sent to the different handling function
%   for plotting. In addition, we calculate the average, the std and plot
%   them in addition to the individual arenas

amountOfArenas = length(allFilesNames);

%% Getting all mat files in the folder
dataInput = allFilesNames;
AllArenas = mergeArenas(amountOfArenas,dataInput); %getting output from the Ctrax and adapting it to the code


%% plotting each arena
AverageOfAllArenas=[];
img = figure('Name',strcat('PI Calculation Experiment - ', outputName),'NumberTitle','off', 'Visible', 'on');
%plotting the six arenas

for numOfarena=1:amountOfArenas
    subplot(3,6,numOfarena);
    ligthIndex = load(dataInput{numOfarena});
    ligthIndex = [ligthIndex.middleX];
    AverageOfAllArenas = [AverageOfAllArenas,;HandlingOneArena(AllArenas{numOfarena} , ligthIndex , lightIsOnLeft, numberOfFlies(numOfarena))];
    title('Preference Index')
end

%% handling the average of all 
%plotting the average and the std of all arenas

subplot (3,6,[13 18]);

HandlingAverageOfArenas(AverageOfAllArenas, amountOfArenas, outputName, experiment, expName);
title('Average PI per frame')
set(gcf,'Position',[70 50 1100 590]) %clean location for tha window

if experiment.returnedData.graphs
    set(gcf, 'Visible', 'on');
    graphName = strcat(outputName, '-pi.jpg');
    saveas(gcf ,graphName);
end
end

function [AllArenas] = mergeArenas(numOfArenas , input)
%UNTITLED Merging the output of the 6 arenas to a data structure
    % here we take out the 6 arenas from the program, merge them to one
    % list and send the, back to the main for further processing
%
for num=1:numOfArenas
    temp = load(input{num});
    tryAr = [temp.identity,temp.x_pos];
    AllArenas{num}=tryAr;
end

end

%Handling the data for one single arena for output- adapting the data from
%the program to plotting and for the final average.

function[forIndex] = HandlingOneArena(arena, ligthIndex, lightIsOnLeft, numberOfFlies)
%% Creating useful data
final=[]; %creating matrix with flies in different positions
for n = 1:numberOfFlies %to amount of flies
indx=arena(:,1)==arena(n,1);
clmn=arena(indx,:);
final=[final,clmn(:,2)];
end

%% creating matrix for index and plotting
forIndex=[]; %matrix for PI
for row=1:size(final,1)%iterating over the rows to find position of each fly
   aboveP=0;underP=0;
    for col=1:size(final,2)
        if(lightIsOnLeft) % light is on the left side of the arena
             if(final(row,col)<=ligthIndex)
                  aboveP = aboveP+1;
             else
              underP=underP+1;
             end
        else % light is on the right side of the arena
            if(final(row,col)>=ligthIndex)
                aboveP = aboveP+1;
             else
              underP=underP+1;
            end
        end
    end
    forIndex(row)= (aboveP-underP)/(aboveP+underP);
end
%plotting

p=plot(forIndex);
xlabel('frame')
ylabel('PI'), p.Marker ='*';
axis tight;
ylim ([-1 1]);
line(get(gca,'XLim'), [0 0],'Color', 'k');

end

function [] = HandlingAverageOfArenas(AllArenas,amountOfArenas,outputName, experiment, expName)
%HANDLINGAVERAGEOFARENAS taking care of the average of all the arenas for
%plotting and plotting

y = mean(AllArenas);
err = std(AllArenas)/sqrt(amountOfArenas-1);
shadedErrorBar([],y,err,'-');
xlabel('frame')
ylabel('Average PI');
line(get(gca,'XLim'), [0 0],'Color', 'k');
axis tight;
xlim ([0 length(y)]);
ylim ([-1 1]);


header = {};
excelName = strcat(outputName, '-pi.xlsx');
if experiment.returnedData.excel
    if experiment.arena.pi
        for i = 1:amountOfArenas
            header = [header, strcat('arena_', num2str(i))];
        end
        data = num2cell(AllArenas.');
        xlswrite(excelName, [header; data], char('arena''s data'))
        arenaAverage = mean(AllArenas.').';
        experimentName = repmat({expName}, 1, amountOfArenas);
        experimentName = experimentName.';
        arenaNumbers = (1:amountOfArenas).';
        T = table(experimentName, arenaAverage, arenaNumbers);
        writetable(T, excelName, 'Sheet', 'arena''s average');
    end
    if experiment.multiple.pi
        data = num2cell(y.');
        xlswrite(excelName, [{'average'}; data], char('average data'))
    end
end


if experiment.returnedData.mat
    matName = strcat(outputName, '-pi.mat');
    if experiment.arena.pi
        for i = 1:amountOfArenas
            curAverage = AllArenas(i,:);
            vecName = strcat('arena_', num2str(i), '_average_pi');
            eval([vecName '= curAverage']);
            if exist(matName, 'file') == 2
                save(matName, vecName, '-append');
            else
                save(matName, vecName);
            end
        end
    end
    if experiment.multiple.pi
        curAverage = y;
        vecName = strcat('overall_average_pi');
        eval([vecName '= curAverage']);
        if exist(matName, 'file') == 2
            save(matName, vecName, '-append');
        else
            save(matName, vecName);
        end
    end
end
end