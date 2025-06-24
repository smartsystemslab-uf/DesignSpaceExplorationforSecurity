import clingo

# Specify the ASP files to load
optimization_programs = [
    "Clingo/init_enc.lp",
    #"Clingo/opt_latency_enc.lp",
    #"Clingo/opt_power_enc.lp",
    #"Clingo/opt_resource_enc.lp",
    "Clingo/opt_security_enc.lp",
    #"Clingo/security_features_inst.lp",
    #"Clingo/tgt_system_inst.lp",
    #"Clingo/usr_constraints_inst.lp",
    "testCases/testCase1_inst.lp"
]

def main():
    # Instantiate the Clingo control object
    ctl = clingo.Control()

    # Load the specified ASP files into Clingo
    for program in optimization_programs:
        ctl.load(program)

    # Ground the loaded programs
    ctl.ground([("base", [])])

    # Function to display the model
    def on_model(model):
        print("Answer Set:")
        print(model)

    # Solve the loaded and grounded program, and print the results
    ctl.solve(on_model=on_model)

if __name__ == "__main__":
    main()