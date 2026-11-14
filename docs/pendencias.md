# Pendências

## Antes da entrega

- [ ] **Tirar o código decompilado do jogo original do repositório e do histórico.**
  A pasta `docs/referencia-original/` tem os scripts, as cenas e os screenshots do Emplake do professor (os direitos são dele). Ela entrou no primeiro commit (`798b459`) e já foi enviada ao GitHub.
  Remover só num commit novo não basta, porque continua no histórico. Passos:
  1. Guardar uma cópia local fora do repositório, se ainda for útil como referência.
  2. Reescrever o histórico sem a pasta:
     `git filter-repo --path docs/referencia-original --invert-paths`
     (instalar com `pip install git-filter-repo`).
  3. Religar o remoto (o filter-repo remove o `origin`) e fazer `git push --force origin main`.
  4. Avisar o Caio: ele precisa clonar de novo, ou fazer `git fetch` + `git reset --hard origin/main`, senão o histórico antigo volta no próximo push dele.
  5. Na seção 10 de `docs/engenharia-reversa-emplake.md`, trocar as referências à pasta por "material local, fora do repositório".
- [ ] Deixar o repositório no GitHub **privado** e adicionar o Caio como colaborador.

## Firebase

- [ ] Restringir a API key do navegador no Google Cloud Console (sites: `localhost`, `emplake-ddm-6ab5b.web.app`, `emplake-ddm-6ab5b.firebaseapp.com`) e fechar o alerta do GitHub como "Won't fix" (a chave do Firebase web é pública por design; quem protege os dados são as regras do Firestore).
- [ ] Confirmar no console que E-mail/senha e Google estão ativados em Authentication.
- [ ] Pegar o "ID do cliente da Web" do provedor Google (para o login com Google na web).
