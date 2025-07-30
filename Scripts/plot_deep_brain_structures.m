function h_figure = plot_deep_brain_structures(file_list, view_side, use_light)
% plot_deep_brain_structures: Loads and plots various deep brain structures from .mat files.
%
%   h_figure = plot_deep_brain_structures(file_list, view_side, use_light)
%
%   Inputs:
%       file_list   : Cell array of strings, where each string is a path to a .mat file
%                     containing a 'cortex' struct with 'vert' and 'tri' fields.
%       view_side   : 'l' for left view (default), 'r' for right view.
%       use_light   : 1 to use lighting (default), 0 otherwise.
%
%   Output:
%       h_figure    : Handle to the created figure.

if nargin < 2 || isempty(view_side)
    view_side = 'l'; % Default to left view
end
if nargin < 3 || isempty(use_light)
    use_light = 1; % Default to use lighting
end

h_figure = figure;
hold on;
axis off;
axis equal;

% Key: Base structure name (e.g., 'Amgd', 'Caud', 'pial', 'BrainStem')
% Value: { [R G B], FaceAlpha }
structure_visual_props = containers.Map('KeyType', 'char', 'ValueType', 'any');

structure_visual_props('pial') = {[0.6 0.6 0.6], 0.15}; % Slightly transparent grey

% Subcortical Structures
structure_visual_props('Acumb') = {[0.9 0.4 0.1], 0.3}; % Orange
structure_visual_props('Amgd') = {[0.8 0.2 0.2], 0.3}; % Red
structure_visual_props('Caud') = {[0.2 0.2 0.8], 0.3}; % Blue
structure_visual_props('GP') = {[0.6 0.1 0.6], 0.3}; % Dark Purple
structure_visual_props('Hipp') = {[0.2 0.8 0.2], 0.3}; % Green
structure_visual_props('Put') = {[0.1 0.7 0.7], 0.3}; % Teal
structure_visual_props('Thal') = {[0.7 0.7 0.1], 0.3}; % Yellow/Gold

% Ventricles
structure_visual_props('FourthVent') = {[0.4 0.7 0.9], 0.2}; % Light Blue, more transparent
structure_visual_props('InfLatVent') = {[0.4 0.7 0.9], 0.2};
structure_visual_props('LatVent') = {[0.4 0.7 0.9], 0.2};
structure_visual_props('ThirdVent') = {[0.4 0.7 0.9], 0.2};
structure_visual_props('VentDienceph') = {[0.4 0.7 0.9], 0.2}; % Assuming this is also a ventricle/fluid space

% Brainstem
structure_visual_props('BrainStem') = {[0.5 0.5 0.5], 0.4}; % Solid grey/darker grey

for i = 1:length(file_list)
    
        data = load(file_list{i});
        if isfield(data, 'cortex') && isfield(data.cortex, 'vert') && isfield(data.cortex, 'tri')
            verts = data.cortex.vert;
            tris = data.cortex.tri;
            [~, name, ~] = fileparts(file_list{i});
            base_name = '';
            if contains(name, 'cvs_avg35_inMNI152_lh_pial') || contains(name, 'cvs_avg35_inMNI152_rh_pial')
                base_name = 'pial';
            elseif contains(name, '_subcort')
                % Remove 'l' or 'r' prefix and '_subcort' suffix
                base_name = name(2:end-8); % e.g., 'lAmgd_subcort' -> 'Amgd'
                if strcmp(base_name, 'BrainStem') % BrainStem might not have l/r prefix
                    base_name = 'BrainStem';
                end
            end

            if structure_visual_props.isKey(base_name)
                props = structure_visual_props(base_name);
                current_color = props{1};
                current_alpha = props{2};
            else
                current_color = [0.7 0.7 0.7];
                current_alpha = 0.5;
            end

            p = patch('Faces', tris, 'Vertices', verts, 'FaceColor', current_color, 'EdgeColor', 'none', 'FaceAlpha', current_alpha);

            % Set DisplayName for legend, making it more readable
            % e.g., 'Left Amygdala', 'Right Caudate', 'Pial'
            display_name = base_name;
            if startsWith(name, 'l') && ~strcmp(base_name, 'BrainStem') && ~strcmp(base_name, 'pial')
                display_name = ['Left ' base_name];
            elseif startsWith(name, 'r') && ~strcmp(base_name, 'BrainStem') && ~strcmp(base_name, 'pial')
                display_name = ['Right ' base_name];
            elseif strcmp(base_name, 'pial')
                if contains(name, 'lh_pial')
                    display_name = 'Left Hemisphere Pial';
                else
                    display_name = 'Right Hemisphere Pial';
                end
            end
            p.DisplayName = display_name;
            fprintf('Successfully loaded and plotted: %s (as %s, color: [%.1f %.1f %.1f], alpha: %.1f)\n', file_list{i}, display_name, current_color, current_alpha);
        end

        % if use_light
        %     l = light;
        %     if view_side == 'l'
        %         view(270, 0);
        %         set(l, 'Position', [-1 0 1]);
        %     elseif view_side == 'r'
        %         view(90, 0);
        %         set(l, 'Position', [1 0 1]);
        %     end
        % end
        lighting gouraud;
        material([.3 .8 .1 10 1]);
        legend('show', 'Location', 'bestoutside');
        title('3D Visualization of Brain Structures in MNI152');
        hold off;

    
end