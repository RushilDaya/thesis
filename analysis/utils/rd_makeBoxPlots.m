
function makeBoxPlots( Data, colors, xlabels, legend_text )
%MAKEBOXPLOTS Summary of this function goes here
%   Detailed explanation goes here

    num_cond = size(Data,3);
    step_size = 1/(num_cond+1);
    assert(num_cond == numel(colors));

    X = zeros(size(Data,1), size(Data,2)*num_cond);
    positions = zeros(1, size(X,2));
    final_colors = cell(1, size(X,2));
    for i = 1 : size(Data,2)
        X(:,(i-1)*num_cond+1:i*num_cond) = squeeze(Data(:,i,:));
        positions((i-1)*num_cond+1:i*num_cond) = linspace((i-(num_cond-1)/2*step_size), (i+(num_cond-1)/2*step_size), num_cond);
        final_colors((i-1)*num_cond+1:i*num_cond) = fliplr(colors);
    end

    boxplot(X, 'Positions', positions, 'factorseparator', 'auto', 'Widths', 0.06);
    
    set(gca,'xtick', (1 : size(Data,2)));
    set(gca,'xticklabel',xlabels);
    xlim([0.5, size(Data,2)+0.5]);

    h = findobj(gca,'Tag','Box');
    for j=1:length(h)
       patch(get(h(j),'XData'),get(h(j),'YData'),final_colors{j},'FaceAlpha',.4, 'EdgeColor', final_colors{j});
    end
    
    lines = findobj(gca, 'Tag', 'Median');
    for j = 1 : length(lines)
       set(lines(j), 'Color', final_colors{j}, 'LineWidth', 3.0); 
    end
    
    outliers = findobj(gca, 'Tag', 'Outliers');
    for j = 1 : length(outliers)
        set(outliers(j), 'MarkerSize', 4, 'MarkerEdgeColor', final_colors{j});
    end
    
    upWisk = findobj(gca, 'Tag', 'Upper Whisker');
    for j = 1 : length(upWisk)
       set(upWisk(j), 'Color', final_colors{j}, 'LineStyle', '-'); 
    end
    
    lowWisk = findobj(gca, 'Tag', 'Lower Whisker');
    for j = 1 : length(lowWisk)
       set(lowWisk(j), 'Color', final_colors{j}, 'LineStyle', '-'); 
    end
    
    upVal = findobj(gca, 'Tag', 'Upper Adjacent Value');
    for j = 1 : length(lowWisk)
       set(upVal(j), 'Color', final_colors{j}, 'LineStyle', '-'); 
    end
    
    lowVal = findobj(gca, 'Tag', 'Lower Adjacent Value');
    for j = 1 : length(lowWisk)
       set(lowVal(j), 'Color', final_colors{j}, 'LineStyle', '-'); 
    end
    
    if num_cond > 1
        c = get(gca, 'Children');
        legend(c(1:num_cond), legend_text, 'Location', 'SouthEast', 'AutoUpdate', 'off');
    end
end

