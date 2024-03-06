@template (FUNCTIONS, METHODS, MACROS) = """
                                         $(FUNCTIONNAME)
                                         $(DOCSTRING)

                                         ---
                                         # Signatures
                                         $(TYPEDSIGNATURES)
                                         ---
                                         ## Methods
                                         $(METHODLIST)
                                         """

@template (TYPES) = """
                    $(TYPEDEF)
                    $(DOCSTRING)

                    ---
                    ## Fields
                    $(TYPEDFIELDS)
                    """

@template MODULES = """
                    $(DOCSTRING)

                    ---
                    ## Exports
                    $(EXPORTS)
                    ---
                    ## Imports
                    $(IMPORTS)
                    """
