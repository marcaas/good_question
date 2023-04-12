\RequirePackage{expl3}
\ProvidesExplClass {CAShomework} {2022/09/12} {v0.1} {a homework class for CAS}

\LoadClass { ctexart }

\clist_map_function:nN
  {
    libertinus-otf,
    unicode-math, 
    geometry,
    fancyhdr,
    enumitem,
    mathtools,
    xpatch,
    amsthm,
    thmtools,
    fixdif,
    physics2,
    xcolor,
    ninecolors,
    listings,
    tabularray,
    tasks,
  } \RequirePackage 

% \RequirePackage[ebgaramond]{fontsetup}

\UseTblrLibrary{booktabs}
\UseTblrLibrary{siunitx}
\UseTblrLibrary{diagbox}
\usephysicsmodule{ab}
\usephysicsmodule[empty={}]{diagmat}

\cs_set_eq:NN \DeclareDocumentCommand:Nnn \DeclareDocumentCommand

\cs_generate_variant:Nn \DeclareDocumentCommand:Nnn { cnn }

% \setmainfont { TeX~ Gyre~ PagellaX }

% \setsansfont { TeX~ Gyre~ Heros }

% \setmonofont { Iosevka~ Slab }

% \setmathfont { NewCMMath-Book.otf }
% \setmathfont { Garamond-Math } 
%   [
%     math-style = TeX
%   ]
\setmathfont { NewCMMath-Book.otf }
  [
    range = {cal, "29F5},
  ]

% \setCJKmainfont { Source~ Han~ Serif~ SC }

\setCJKsansfont { Source~ Han~ Sans~ SC }

\xpatchcmd { \@maketitle } { \@title } { \bfseries \@title } { } { \false }

\geometry { a4paper, margin = 2cm }

\fancyhf { }
\fancyhead [ L ] { \@title }
% \fancyhead [ R ] { \rightmark }
\fancyfoot [ C ] { -\thepage- }

\let\proof\relax
\let\endproof\relax

\declaretheorem [ name = 问题, style = definition, numberwithin = section ] { question }

\declaretheorem [ name = 证明, numbered = no, style = definition, qed=\qedsymbol ] { proof }

\declaretheorem [ name = 解, numbered = no, style = definition ] { solution }

\DeclarePairedDelimiter \tmp_norm { \lVert } { \rVert }
\DeclarePairedDelimiterX \lrangle [ 2 ] { \langle } { \rangle } { #1, #2 }

\newcommand{\VertTmp}{}
\NewDocumentCommand \norm { s o o m }
  {
    \IfBooleanTF { #1 }
      { \renewcommand {\VertTmp} { \tmp_norm* } }
      { \renewcommand {\VertTmp} { \tmp_norm  } }
    \IfValueTF { #3 }
      {
        \IfValueTF { #2 }
          { \VertTmp [ #3 ] { #4 } \sb { #2 } }
          { \VertTmp [ #3 ] { #4 } }
      }
      {
        \IfValueTF { #2 }
          { \VertTmp { #4 } \sb { #2 } }
          { \VertTmp { #4 } }
      }
  }

\clist_new:N \l_CAS_bb_clist
\clist_set:Nn \l_CAS_bb_clist { N, Z, Q, J, R, C, K, F, E }
\clist_map_inline:Nn \l_CAS_bb_clist 
  {
    \DeclareDocumentCommand:cnn { #1 } { } { \symbb{#1} }
  }


\msg_new:nnn { counter-example } { Seq-4th-not-int } 
  { 
    \msg_line_context: \\
    The~second~mandatory~parameter\\
    should~be~an~integer~in~\protect\Seq*
  }
\int_new:N \l__ce_tmpa_int
% https://tex.stackexchange.com/questions/427557/how-to-test-if-an-expl3-function-argument-is-an-integer-expression
\prg_new_protected_conditional:Npnn \if_is_int:n #1 { T, F, TF }
  {
    \regex_match:nnTF { \A[\+\-]?[\d]+\Z } { #1 }
      { \prg_return_true: }
      { \prg_return_false: }
  }

\cs_new:Npn \__ce_Seq_star:nnnn #1#2#3#4
  {
    \if_is_int:nTF { #3 }
      {
        \int_compare:nNnT { #3 } > { #2 }
        \int_set:Nn \l__ce_tmpa_int { #2 }
        #1\sb{\int_use:N \l__ce_tmpa_int}
        \int_do_until:nNnn { \l__ce_tmpa_int } = { #3 }
          {
            \int_incr:N \l__ce_tmpa_int
            #4 #1\sb{ \int_use:N \l__ce_tmpa_int }
          }
      }
      {\msg_error:nn { counter-example } { Seq-4th-not-int }}
  }

\cs_new:Npn \__ce_Seq_no_star:nnnn #1#2#3#4
  {
    \if_is_int:nTF { #3 }
      {
        \int_case:nnF { #3 }
          {
            { #2 + 1 } { #1\sb{#2}#4 #1\sb{#3} }
            { #2 + 2 } { #1\sb{#2}#4 #1\sb{\int_eval:n { #2 + 1 }}#4 #1\sb{#3}}
          }
          {
            #1\sb{#2}#4  #1\sb{\int_eval:n { #2 + 1 }}#4 \dots#4~#1\sb{#3}
          }
      }
      {
        #1\sb{#2}#4 #1\sb{\int_eval:n { #2 + 1 }}#4 
        \tl_if_blank:nTF { #4 } {\cdots} {\dots}
        #4 #1\sb{#3}
      }
  }
\NewDocumentCommand \Seq { s m O{1} m O{,} }
{
  \IfBooleanTF { #1 }
    { \__ce_Seq_star:nnnn { #2 } { #3 } { #4 } { #5 } }
    { \__ce_Seq_no_star:nnnn { #2 } { #3 } { #4 } { #5 } }
}

% 生成 V 变体来接受 tl 类型数据
\prg_generate_conditional_variant:Nnn \tl_if_head_eq_meaning:nN { V N } { T, F, TF }
% 系数向量 clist
\clist_new:N \l__cf_polynomial_clist
% 系数
\tl_new:N \l__cf_polynomial_coefficient_tl
% 最高次数
\int_new:N \l__cf_polynomial_degree_int
% 每一项的次数
\int_new:N \l__cf_polynomial_power_int
% 主函数
\cs_new:Npn \__cf_polynomial:nn #1#2
  {
    \clist_set:Nn \l__cf_polynomial_clist { #1 }
    % 用 clist 的项数 - 1 来确定最高次数
    \int_set:Nn \l__cf_polynomial_degree_int { \int_eval:n { \clist_count:N \l__cf_polynomial_clist - 1 } }
    % 初始化次数为最高次数
    \int_set_eq:NN \l__cf_polynomial_power_int \l__cf_polynomial_degree_int
    \int_do_until:nNnn { \int_use:N \l__cf_polynomial_power_int } < { 0 }
      {
        % 将 clist 第一项 pop 出, 存入 coefficient. 
        \clist_pop:NN \l__cf_polynomial_clist \l__cf_polynomial_coefficient_tl
        % 如果 coefficient 为 0, 直接进入下一次循环
        \tl_if_eq:NnTF \l__cf_polynomial_coefficient_tl { 0 }
          {
            % 如果是零多项式, 直接输出 0, 否则跳过系数为 0 的项.
            \int_compare:nNnT { \l__cf_polynomial_degree_int } = { 0 }
              { 0 }
          }
          { \__cf_polynomial_monomial:n { #2 } }
        % 次数 - 1
        \int_decr:N \l__cf_polynomial_power_int
      }
  }

% 输出每个单项式的函数
\cs_new:Npn \__cf_polynomial_monomial:n #1 
  {
    % 如果这一项次数为 0, 则判断最高次数是否也为 0, 进行常数项输出
    % 如果这一项次数不为 0, 则以 系数+x^k 的形式输出
    \int_compare:nNnTF { \int_use:N \l__cf_polynomial_power_int } = { 0 } 
    {
      % 最高次数如果不为 0, 且系数不是以 - 开头, 那么添加 + 
      % 如果为 0, 或以 -  开头则直接输出, 
      \int_compare:nNnF 
        { \int_use:N \l__cf_polynomial_degree_int } = { 0 }
        {
          \tl_if_head_eq_meaning:VNF \l__cf_polynomial_coefficient_tl - { + }
        }
      \tl_use:N \l__cf_polynomial_coefficient_tl
    } 
    { \__cf_polynomial_coefficient: \__cf_polynomial_x:n { #1 } }
  }

% 输出单项式的系数
\cs_new:Npn \__cf_polynomial_coefficient: 
  {
    % 如果系数以 - 开头, 判断是否为 -1
      % 如果为 -1, 系数变为 -, 如果不为 -1, 原样输出
    % 如果系数不以 - 开头, 判断是否为最高次项的系数
      % 如果是最高次项的系数, 原样输出, 
      % 如果不是最高系数, 为系数添加 +
        % 如果次数为 1, 则不输出 1
    \tl_if_head_eq_meaning:VNTF \l__cf_polynomial_coefficient_tl -
      { 
        \tl_if_eq:NnTF \l__cf_polynomial_coefficient_tl { -1 } 
          { - } 
          { \tl_use:N \l__cf_polynomial_coefficient_tl } 
      }
      { 
        \int_compare:nNnF 
          \l__cf_polynomial_power_int =
          \l__cf_polynomial_degree_int
          { + }
          \tl_if_eq:NnF \l__cf_polynomial_coefficient_tl { 1 }
            { \tl_use:N \l__cf_polynomial_coefficient_tl }
      }
  }

% 输出单项式的 x 项
\cs_new:Npn \__cf_polynomial_x:n #1
  {
    % 如果次数为 1, 直接输出 'x'
    % 如果次数为 0, 则不输出
    % 否则输出幂次
    \int_case:nnF { \l__cf_polynomial_power_int }
      {
        { 1 } { #1 }
        { 0 } {    }
      }
      { #1\sp{\int_use:N \l__cf_polynomial_power_int} }
  }

\NewDocumentCommand \Poly { O{x} m } { \__cf_polynomial:nn { #2 } { #1 } }

\DeclarePairedDelimiter\abs{\lvert}{\rvert}
% \DeclarePairedDelimiter\norm{\lVert}{\rVert}

\NewDocumentCommand \limit { m } { \lim\limits \c_math_subscript_token { #1 } }
\AtBeginDocument{
    \let\ge\geqslant
    \let\le\leqslant
    % \renewcommand\pi{\symup\umathpi}%
}
\DeclareMathOperator{\rank}{rank}
\DeclareMathOperator{\tr}{tr}
\DeclareMathOperator{\cl}{cl}
\DeclareMathOperator{\epi}{epi}
\DeclareMathOperator{\Span}{span}
\DeclareMathOperator{\diag}{diag}
\DeclareMathOperator*{\argmin}{argmin}
\DeclareMathOperator{\Image}{Im}
\DeclareMathOperator{\Ker}{Ker}
\DeclareMathOperator{\aff}{aff}
\DeclareMathOperator{\conv}{conv}
\DeclareMathOperator{\cone}{cone}
\DeclareMathOperator{\ri}{ri}
\DeclareMathOperator{\Int}{int}
\DeclareMathOperator{\rbd}{rbd}
\DeclareMathOperator{\bd}{bd}
% \DeclareMathOperator{\det}{det}

\NewDocumentCommand \me { } { \symup{e} }
\NewDocumentCommand \mi { } { \symup{i} }

\NewDocumentCommand \tran { } { \sp{\mathsf{T}} }
\NewDocumentCommand \htran { } { \sp{*} }
\letdif*{\p}{partial}
\letdif*{\grad}{nabla}
  
\DeclareDocumentCommand \hom { m } { \symcal{#1} }
% \let\SS = \oldSS
\RenewDocumentCommand \SS { s s O{n} } 
  {
    \IfBooleanTF { #1 } 
      {
        \IfBooleanTF { #2 }
          { \symbb{S}\sb{++}^{#3} }
          { \symbb{S}\sb{+}^{#3} }
      }
      {
        \symbb{S}^{#3}
      }
  }


\lstset
{
  basicstyle  =   \ttfamily\small,
  breaklines,
  frame       =   leftline,
  gobble      =   2,
  framerule   =   1pt,
  prebreak    =   {\mbox{$ \Ldsh $}},
  postbreak   =   {\mbox{$ \hookrightarrow $\quad}},
  breakindent =   10pt,
}

\lstnewenvironment{matlabcode}{\lstset{language=matlab}}{}
\NewDocumentCommand \matlab { } { \lstinline[language=matlab] }

\lstdefinelanguage{matlab}{
    alsoletter      ={...},%
    morekeywords    = [1]
    {%                             % keywords
          break, case,
          catch, classdef, continue, contour,
          else, elseif, end,
          for, function, 
          global, 
          if,
          length,
          otherwise,
          parfor, permute, persistent, PetscBinaryRead, polyfit, polyval,
          reshape, return,
          spmd, switch,
          try, 
          while,
          zeros,
          ...,
    },
    morecomment     =[l][\color{gray6}\itshape]\%,                              % comments
    morecomment     =[l][\color{gray6}\itshape]...,                         % comments
    morecomment     =[s][\color{gray6}\itshape]{\%\{}{\%\}},                % block comments
    morestring      =[b]",
    sensitive,
    keywordstyle    = [1]{\bfseries},
    rulecolor       = {\color{olive4}},
}