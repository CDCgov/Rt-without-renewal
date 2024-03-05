@template (FUNCTIONS, METHODS, MACROS) = """
                                         $(FUNCTIONNAME)
                                         $(DOCSTRING)

                                         ---
                                         # Signatures
                                         $(TYPEDSIGNATURES)
                                         ---
                                         ## Methods
                                         $(METHODLIST)
                                         ---
                                         ## Fields
                                         $(TYPEDFIELDS)
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
