

@testset "Testing random_walk function" begin
    # Test case 1: Testing against theoretical properties
    @testset "Test case 1" begin
        n = 5
        model = random_walk(n)
        fixed_model = fix(model, (σ²_RW = 1.0,)) #Fixing the standard deviation of the random walk process
        n_samples = 1000
        samples_day_5 =
            sample(fixed_model, Prior(), n_samples) |>
            chn -> mapreduce(vcat, generated_quantities(fixed_model, chn)) do gen
                gen[1][5]
            end
        #Check statistics are within 5 sigma
        #Theoretically, after 5 steps distribution is N(0, var = 5)
        theoretical_std_of_empiral_mean = sqrt(5 / n_samples)
        @test mean(samples_day_5) < 5 * theoretical_std_of_empiral_mean &&
              mean(samples_day_5) > -5 * theoretical_std_of_empiral_mean

        #Theoretically, after 5 steps distribution is N(0, var = 5)



        theoretical_std_of_empiral_var = std(Chisq(5)) / sqrt(n_samples)
        @test (var(samples_day_5) - 5) < 5 * theoretical_std_of_empiral_var &&
              (var(samples_day_5) - 5) > -5 * theoretical_std_of_empiral_var

    end

end
