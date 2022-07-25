# Naming Convention
The convention is modified from the Java convention suggested by [Sun Microsystems, Inc.](http://www.oracle.com/technetwork/java/codeconventions-135099.html)


<table>
<thead>
<tr class="header">
<th> Test Change</th>
<th>Naming Convention</th>
<th>Examples</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>Folders</td>
<td>Use <code class="highlighter-rouge">snake_case</code>. All letters are lower case and words are separated by underscores <code class="highlighter-rouge">_</code>. Names should be short and descriptive.</td>
<td>cofe_solvers</td>
</tr>
<tr class="even">
<td>Classes</td>
<td>Use <code class="highlighter-rouge">UpperCamelCase</code>. Class names should be nouns, in mixed case with the first letter of each internal word capitalized. Try to keep your class names simple and descriptive. Use whole words-avoid acronyms and abbreviations (unless the abbreviation is much more widely used than the long form, such as URL or HTML).</td>
<td>InputFile;<br>Beam;</td>
</tr>
<tr class="odd">
<td>Functions</td>
<td>Use <code class="highlighter-rouge">lowerCamelCase</code>. Functions should be verbs, in mixed case with the first letter lower case, with the first letter of each internal word capitalized.</td>
<td>run();<br>runFast();<br>getBackground();</td>
</tr>
<tr class="even">
<td>Variables</td>
<td>Use <code class="highlighter-rouge">lowerCamelCase</code>. Variables including class instances (objects) should be mixed case with a lower case first letter. Internal words start with capital letters. Variable names should be short yet meaningful. The choice of a variable name should be mnemonic- that is, designed to indicate to the casual observer the intent of its use. One-character variable names should be avoided except for temporary variables. Common names for temporary variables are <code class="highlighter-rouge">i, j, k, m, and n</code> for integers. CoFE class instances of user-defined classes are often the class name changed from <code class="highlighter-rouge">UpperCamelCase</code> to <code class="highlighter-rouge">lowerCamelCase</code>. <b>See exceptions for special variable names below.</b></td>
<td>startNumber<br>i;<br>myWidth</td>
</tr>
<tr class="odd">
<td>Constants</td>
<td>The names of variables declared class constants should be all uppercase with words separated by underscores <code class="highlighter-rouge">_</code>.</td>
<td>MIN_WIDTH = 4;<br>MAX_WIDTH = 999;<br>GET_THE_CPU = 1;</td>
</tr>
</tbody>
</table>


## Special Class Names for Nastran Input Entries 
Classes representing Nastran input entries have special names which should be documented here. 

## Special Function Names for Hierarchical Interface Functions

CoFE uses a hierarchical approach for interfacing with heterogeneous arrays of objects. Heterogeneous arrays are composed of objects that differ in specific class, but are all subclasses of a common root superclass (the common superclass derives directly from matlab.mixin.Heterogeneous). A separate CoFE documentation page should be dedicated to object composition so that this Naming Convention page is not inflated with this information. 

In CoFE, certain subclass methods (of heterogeneous array objects) are invoked through superclass interface methods (that are sealed at the superclass level). In these cases, the subclass method name is the superclass interface method name appended with `_sub`. For example, the following `echo()` function is a sealed superclass method used to echo (i.e., print) data from a heterogeneous array of objects. All subclasses implement an `echo_sub()` function, which is called by `echo()`.  

```matlab
    methods (Sealed = true)
        function echo(obj,fid)
	% Execute entry.echo_sub(fid) for all heterogeneous entry objects in array
            [n,m]=size(obj);
            if m > 1; error('This function can only handle nx1 arrays of objects.'); end
            for i=1:n
                echo_sub(obj(i),fid);
            end
        end
    end
```

## Special Variable Names
Special variable names are used in the following cases:

### Nastran input entry field names
Variables representing Nastran input entry fields should almost always be the Nastran input entry field name in lower case. Nastran input entry field names are well-documented in Nastran and CoFE user manuals and should be documented in the class properties section of specific input entry classes.

### Engineering mechanics symbols
Commonly used symbols for engineering mechanics variables are used even if those symbols deviate from programming convention (e.g., `K` is used rather than `stiffnessMatrix`). Typically, capital letters are used for symbols that represent two dimensional arrays (matrices) while lower case letters are used for one dimensional arrays and scalars; however, it's preferable to stick to the conventional case when there is a strongly established convention (e.g., use `E` rather than `e` for Young's modulus).

### Coordinate reference frames and transformations

Underscores `_` are appended to variable names to designate coordinate reference frames and coordinate transformations. The character following the underscore specifies the reference frame. For example, `x_0` and `x_g` are the vector `x` expressed in the `0` and `g` references frames, respectively. 

Capital `T` is used for 3x3 transformation matrices and capital `R` is used for other size transformation matrices. The first character following the underscore designates the reference frame being transformed to and the second character designates the reference frame being transformed from. For example, `T_g0` is transforms a 3x1 vector from the `0` reference frame to the `g` reference frame, so `x_g = T_g0 * x_0`.
