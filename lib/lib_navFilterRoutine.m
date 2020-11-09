function [navFilter,measDb] = lib_navFilterRoutine(navFilter,measDb,ttag)

    [navFilter,filOk] = navFilter.checkMeas(measDb);

    if filOk
        switch navFilter.getMode()
            case FilterMode.IDLE
                % do nothing
            case FilterMode.INIT
                if filOk
                    [navFilter,filOk] = navFilter.initState(measDb);
                end

                if filOk
                    [navFilter,filOk] = navFilter.initCov(measDb);
                end

                if filOk
                    navFilter = navFilter.setMode(FilterMode.RUNNING);
                end
            case FilterMode.RUNNING
                if filOk
                    [navFilter,filOk] = navFilter.propState(measDb);
                end

                if filOk
                    [navFilter,filOk] = navFilter.propCov(measDb);
                end

                if filOk
                    [navFilter,filOk] = navFilter.measUpdate(measDb);
                end

                if filOk
                    [navFilter,filOk] = navFilter.correctState();
                end

                if ~filOk
                    navFilter = navFilter.reset();
                end
            otherwise
                % do nothing
        end
    else
        navFilter = navFilter.reset();
    end
end

