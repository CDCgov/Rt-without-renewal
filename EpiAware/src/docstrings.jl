@template (FUNCTIONS, METHODS, MACROS) = """
                                             $(TYPEDSIGNATURES)
                                         $(DOCSTRING)

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
