function interctionClassifier(flyIdentity, fileName)
load(fileName);
classifier = [(1:length(pairtrx(flyIdentity).distnose2ell))', pairtrx(flyIdentity).distnose2ell' , pairtrx(flyIdentity).anglesub'];
classifier(classifier(:, 3) == 0, :) = [];
classifier(classifier(:, 2) > 8, :) = [];
toDelete = [];

firstFrame = 1;
for i = 2:length(classifier(:, 1))
    if (classifier(i, 1) - classifier(i - 1, 1) > 1)
        if (i - firstFrame < 225)
            toDelete = [toDelete, firstFrame:i - 1];
            firstFrame = i;
        end    
    end
end
if (length(classifier(:, 1)) - firstFrame < 225)
    classifier(firstFrame:end, :) = [];
end 
classifier(toDelete, :) = [];

figure;
hold on;

yyaxis left
plot(pairtrx(flyIdentity).distnose2ell);

if ~isempty(classifier)
    plot(classifier(1, 1), classifier(1, 2), 'ob');
    plot(classifier(end, 1), classifier(end, 2), 'ob');
end

yyaxis right
plot(pairtrx(flyIdentity).anglesub);