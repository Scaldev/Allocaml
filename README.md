# Allocaml

An OCaml implement of allocation of indivisible goods to agents, in the case of *constrained serial dictatorships*, known to be the only strategyproof mechanism satisfying mild conditions.

Based on [Jerome Lang](https://www.lamsade.dauphine.fr/~lang/)'s [CSD can be Fair](https://www.lamsade.dauphine.fr/%7Elang/papers/BGLM25.pdf) article.

## I. Project structure

In `/lib/`.

### I.1. Ranking and profile.

Let $\mathcal{A} = \\{ a_1, \cdots, a_n \\}$ be a set of $n$ agents and $\mathcal{G} = \\{ g_1, \cdots, g_m \\}$ be a set of $m$ goods.

A *ranking* $\succ$ is a permutation of the goods in $\mathcal{G}$ represented as $[g_{\sigma^{-1}(1)} \succ \cdots \succ g_{\sigma^{-1}(m)}]$. We note $\mathcal{L}(\mathcal{G})$ the set of all rankings over $\mathcal{G}$.

```ml
(* ranking.ml *)
val of_list    : 'good list -> 'good Ranking.t
val to_list    : 'good Ranking.t -> 'good list
val to_string  : ('good -> string) -> 'good Ranking.t -> string
val length     : 'good Ranking.t -> int
val is_ranking : 'good Ranking.t -> 'good list -> bool
val rank       : 'good Ranking.t -> 'good -> int
val nth        : 'good Ranking.t -> int -> 'good
```

A *preference profile* $\mathbf{P} = (\succ_{a_1}, \cdots, \succ_{a_n})$ describes the preferences of the agents $\mathcal{A}$ over $\mathcal{G}$: $\succ_{a}$ is a complete ranking over $\mathcal{G}$ that specifies the preferences of agent $a$ over the goods in $\mathcal{G}$.

We denote by $\text{rank}_{\mathbf{P}}^a(g)$ the rank of good $g$ in the ranking of $a$ given profile $\mathbf{P}$.

```ml
(* profile.ml *)
val create     : 'good list -> ('agent, 'good) Profile.t
val to_string  : ('agent -> string) -> ('good -> string) -> ('agent, 'good) t -> string
val add        : ('agent, 'good) Profile.t -> 'agent -> 'good Ranking.t -> unit
val ranking_of : ('agent, 'good) Profile.t -> 'agent -> 'good Ranking.t
val rank       : ('agent, 'good) Profile.t -> 'agent -> 'good -> int
```

### I.2. Probabilistic models

There are two implemented probabilistic models for drawing rankings at random. We define a model as two functions `sample` and `chance` defined below:

```ml
type 'good Model.t = {
    sample : unit -> 'good Ranking.t;
    chance : 'good Ranking.t -> float;
}

val simulate : 'good Model.t -> 'good list -> ('good -> string) -> int -> unit
```

#### I.2.a. Mallows model

The *Mallows model* is parameterized by a dispersion parameter $\varphi \in [0, 1]$ and a central ranking $r^{\star}$. We denote this model by $\texttt{Mll}_{\varphi, r^{\star}}$.

Let $\texttt{sample} = \texttt{Mallows.sample (Mallows.create}$ $\varphi$ $r^{\star}$ $\texttt{)}$.
The probability of sampling a ranking $r \in \mathcal{L}(\mathcal{G})$ under $\texttt{Mll}_{\varphi, r^{\star}}$ is:
$$\mathbb{P}[\texttt{sample ()} = r] = \frac{1}{Z(\varphi, m)} \varphi^{\kappa(r^{\star}, r)}$$
Where $\kappa(r^{\star}, r)$ is the *Kendall-Tau distance* between $r^{\star}$ and $r$, i.e. the number of pairs of goods that are in a different order in the two rankings. Moreover, $Z(\varphi, m)$ is called a normalization constant and is defined as:

$$\quad Z(\varphi, m) = \prod_{j=1}^{m-1} \sum_{i=0}^j \varphi^i = (1 + \varphi) \cdot (1 + \varphi + \varphi^2) \cdot \cdots \cdot (1 + \varphi + \cdots + \varphi^{m-1})$$

For $\varphi = 0$ only $r^{\star}$ is sampled, also known as *Full Correlation*. Using $\varphi = 1$ leads to a uniform distribution over rankings from $\mathcal{L}(\mathcal{G})$, also known as *Impartial Culture (IC)*.

See [this article](https://arxiv.org/pdf/2401.14562) for more.

#### I.2.b. Plackett-Luce model

The *Plackett-Luce model* is parameterized by a *value vector* $\nu = (v_1, \cdots, v_n)$. Intuitively, $v_i > 0$ represents the social value of good $g_i$. We denote this model by $\texttt{PL}_{\nu}$.

Let $\texttt{sample} = \texttt{Plackettluce.sample (Plackettluce.create}$ $\nu$ $\texttt{)}$.

The probability of sampling a ranking $r \in \mathcal{L}(\mathcal{G})$ under $\texttt{PL}_{\nu}$ is :

$$\mathbb{P}[\texttt{sample ()} = r] = \prod_{j=1}^m \frac{\nu_{i_j}}{\sum_{l=j}^m \nu_{i_l}}$$

If all values of $\nu$ are equal, we get a uniform distribution over rankings from $\mathcal{L}(\mathcal{G})$, also known as *Impartial Culture*. If $\nu_M = (M^{m-1}, \cdots, M, 1)$ when $M \to \infty$, only $(g_1, \cdots, g_n)$ is sampled, also known as *Full Correlation*.

In our implementation, we combine goods and values in a single list $\nu$ of type `('good * float) list`. In the *Full Correlation* case, it means that $\texttt{sample ()}$ will always return $\texttt{List.map fst } \nu$.
